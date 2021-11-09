execute 'trigger-ssh-deployment' do
    command "aws --region us-east-1 s3 cp s3://sendhub-keychain/provision.pem /home/ubuntu/.ssh/. ; chmod 600 /home/ubuntu/.ssh/provision.pem ; chown ubuntu:ubuntu /home/ubuntu/.ssh/provision.pem"
    creates "/home/ubuntu/.ssh/provision.pem"
end
