cron "siplog_cleanup" do
  user "ubuntu"
  home "/home/ubuntu"
  command '/sendhub_build/siplog-upload/venv/current/venv/bin/activate ; envdir /sendhub_build/siplog-upload/settings/current /sendhub_build/siplog-upload/src/current/siplog-upload/clear_uploads.py 2>&1 | logger'
end