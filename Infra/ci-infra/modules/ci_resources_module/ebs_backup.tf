

resource "aws_ebs_volume" "ci_master_data_vol" {

  availability_zone = aws_instance.CI_Master.availability_zone # must wait ci master creation to get AZ from it 

  size = 20
  type = "gp3"

  tags = {
    Name = "ci_master_data"
  }

#   lifecycle {
#     prevent_destroy = true # not allow destroy when do terraform destroy
#   }
}



resource "aws_volume_attachment" "attach_vol_to_ci_master" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.ci_master_data_vol.id
  instance_id = aws_instance.CI_Master.id

  # if instance replaced then force detach the old attachment
  force_detach = true 
}


resource "null_resource" "mount_vol_ci_master" {
  triggers = {
    instance_id = aws_instance.CI_Master.id # this null resource work when ci master created or instance id changed 
  }

  depends_on = [ aws_volume_attachment.attach_vol_to_ci_master ,
      null_resource.update_ssh_config,
    null_resource.create_inventory_ini
  ]

# already on local machine configure ~/.ssh/config file
provisioner "local-exec" {
  command = <<EOF
scp \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  ../modules/ci_resources_module/mount_ebs_backup.sh \
  ci-master:/home/ec2-user/mount_ebs_backup.sh

ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  ci-master \
  "chmod +x /home/ec2-user/mount_ebs_backup.sh && sudo /home/ec2-user/mount_ebs_backup.sh"
EOF
}

}

resource "null_resource" "run_ansible_install_jenkins" {
  
  triggers = {
    instance_id = aws_instance.CI_Master.id # this null resource work when ci master created or instance id changed 
  }
  depends_on = [ null_resource.mount_vol_ci_master ] # must work after mount_vol_ci_master

  provisioner "local-exec" {
    working_dir = "../Ansible"
    command = <<EOF
ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventory.ini setup-ci-master.yml
EOF

  }
}