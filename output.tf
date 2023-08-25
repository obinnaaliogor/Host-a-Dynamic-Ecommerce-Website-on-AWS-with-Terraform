#VPC outputs
output "vpc_id" {
 value = aws_vpc.vpc.id
}

#subnets outputs
output "public_subnet_az1" {
  value = aws_subnet.public_subnet_az1.id
}

output "public_subnet_az2" {
  value = aws_subnet.public_subnet_az2.id
}

#ALB output
output "alb_dns_name"{
   value = aws_lb.application_load_balancer.dns_name
}

output "website_url" {
  value = join ("", ["https://", var.a_record, ".", var.hosted_zone ]) #The function join will join the items in the list
}
