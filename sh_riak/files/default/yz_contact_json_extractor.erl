%% -------------------------------------------------------------------
%%
%% Copyright (c) 2012 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc An extractor for JSON.  Nested objects have their fields
%% concatenated with `field_separator'.  An array is converted into a
%% multi-valued field.
%%
%% Example:
%% ```
%%   {"name":"ryan",
%%    "info":{"city":"Baltimore",
%%            "visited":["Boston", "New York", "San Francisco"]}}
%%
%%   [{<<"info_visited">>,<<"San Francisco">>},
%%    {<<"info_visited">>,<<"New York">>},
%%    {<<"info_visited">>,<<"Boston">>},
%%    {<<"info_city">>,<<"Baltimore">>},
%%    {<<"name">>,<<"ryan">>}]
%% '''
%% Options:
%%
%%   `field_separator' - Use a different field separator than the
%%                       default of `.'.

-module(yz_contact_json_extractor).
-compile(export_all).
-define(DEFAULT_FIELD_SEPARATOR, <<".">>).
-define(NO_OPTIONS, []).
-record(state, {
          fields = [],
          field_separator = ?DEFAULT_FIELD_SEPARATOR
         }).
-type state() :: #state{}.
-type field_name() :: atom() | binary().
-type field_value() :: binary().
-type field() :: {field_name(), field_value()}.
-type fields() :: [field()].
-type proplist() :: proplists:proplist().

-spec extract(binary()) -> fields() | {error, any()}.
extract(Value) ->
    extract(Value, ?NO_OPTIONS).

-spec extract(binary(), proplist()) -> fields() | {error, any()}.
extract(Value, Opts) ->
    Sep = proplists:get_value(field_separator, Opts, ?DEFAULT_FIELD_SEPARATOR),
    extract_fields(Value, #state{field_separator=Sep}).

-spec extract_fields(binary(), state()) -> fields().
extract_fields(Value, S) ->
    Struct = mochijson2:decode(Value),
    S2 = extract_fields(undefined, Struct, S),
    S2#state.fields.

-spec extract_fields(binary() | undefined, term(), state()) -> state().
%% Contact Visibility
extract_fields(<<"visibleToUsersTree">>, {struct, JSONFields}, S) ->
    Visibility = lists:foldl(extract_visibility(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"visibleToUsersTree">>), S, sets:to_list(Visibility));

extract_fields(<<"visibleToEnterprisesTree">>, {struct, JSONFields}, S) ->
    Visibility = lists:foldl(extract_visibility(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"visibleToEnterprisesTree">>), S, sets:to_list(Visibility));

%% Phone Numbers
extract_fields(<<"phoneNumbers">>, {struct, JSONFields}, S) ->
    Numbers = lists:foldl(extract_values(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"phoneNumbers">>), S, sets:to_list(Numbers));

%% Emails
extract_fields(<<"emails">>, {struct, JSONFields}, S) ->
    Emails = lists:foldl(extract_values(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"emails">>), S, sets:to_list(Emails));

%% Websites
extract_fields(<<"websites">>, {struct, JSONFields}, S) ->
    Websites = lists:foldl(extract_values(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"websites">>), S, sets:to_list(Websites));

%% Addresses
extract_fields(<<"addresses">>, {struct, JSONFields}, S) ->
    Addresses = lists:foldl(extract_values(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"addresses">>), S, sets:to_list(Addresses));

%% Notes
extract_fields(<<"notes">>, {struct, JSONFields}, S) ->
    Notes = lists:foldl(extract_values(), sets:new(), JSONFields),
    lists:foldl(extract_element(<<"notes">>), S, sets:to_list(Notes));

%% Object
extract_fields(CurrentName, {struct, JSONFields}, S) ->
    lists:foldl(extract_field(CurrentName), S, JSONFields);

%% Array
extract_fields(CurrentName, Array, S) when is_list(Array) ->
    lists:foldl(extract_element(CurrentName), S, Array);

%% null value
extract_fields(_, null, S) ->
    S;

%% Value
extract_fields(CurrentName, Value, S) ->
    Fields = S#state.fields,
    S#state{fields=[{CurrentName, clean_value(Value)}|Fields]}.

-spec extract_field(binary()) -> fun(({binary(), binary()}, state()) -> state()).
extract_field(CurrentName) ->
    fun({Name, Val}, S) ->
            Separator = S#state.field_separator,
            FieldName = new_field_name(CurrentName, Name, Separator),
            extract_fields(FieldName, Val, S)
    end.

-spec extract_element(binary()) -> fun((binary(), state()) -> state()).
extract_element(CurrentName) ->
    fun(Element, S) ->
            extract_fields(CurrentName, Element, S)
    end.

-spec new_field_name(binary() | undefined, binary(), binary()) -> binary().
new_field_name(undefined, FieldName, _) ->
    FieldName;
new_field_name(CurrentName, FieldName, Separator) ->
    <<CurrentName/binary,Separator/binary,FieldName/binary>>.

clean_value(Value) ->
    case is_number(Value) of
        true  -> list_to_binary(mochinum:digits(Value));
        false -> Value
    end.

-spec extract_visibility() -> fun(({binary(), list()}, set()) -> set()).
extract_visibility() ->
    fun({GroupName, GroupVisibility}, AllVisibility) ->
        GroupVisibilitySet = sets:from_list(GroupVisibility),
        sets:union(AllVisibility, GroupVisibilitySet)
    end.

-spec extract_values() -> fun(({binary(), term()}, set()) -> set()).
extract_values() ->
    fun({_, {struct, JSONFields}}, AllNumbers) ->
        {_, Number} = lists:keyfind(<<"value">>, 1, JSONFields),
        sets:add_element(Number, AllNumbers)
    end.