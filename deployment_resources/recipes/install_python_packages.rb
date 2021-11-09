execute "install-aws-cli" do
    command "sudo pip install awscli"
    not_if "test `pip freeze | grep 'awscli=='`"
end
