# create a launch template
# terraform aws launch template
#5 Using Datasource to get an AMI to provision an instance.
data "aws_ami" "my_image" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["fleetcart-application-latest"] #Gets you amazon linux 2 AMI
    #values = ["ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"] #gets you ubuntu AMI
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}
resource "aws_launch_template" "webserver_launch_template" {
  name          = "fleetcart-launch-template"
  image_id      = data.aws_ami.my_image.id
  instance_type = "t2.micro"
  key_name      = "html-key"
  description   = "Launch Template for Fleetcart Application"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.webserver_security_group.id]
}

# create auto scaling group
# terraform aws autoscaling group
resource "aws_autoscaling_group" "auto_scaling_group" {
  vpc_zone_identifier = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  name                = "fleetcart-asg"
  health_check_type   = "ELB"

  launch_template {
    name    = aws_launch_template.webserver_launch_template.name
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-webserver"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [target_group_arns]
  }
}

# attach auto scaling group to alb target group
# terraform aws autoscaling attachment
resource "aws_autoscaling_attachment" "asg_alb_target_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.id
  lb_target_group_arn    = aws_lb_target_group.alb_target_group.arn
}

# create an auto scaling group notification
# terraform aws autoscaling notification
resource "aws_autoscaling_notification" "webserver_asg_notifications" {
  group_names = [aws_autoscaling_group.auto_scaling_group.name]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.user_updates.arn
}