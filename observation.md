1. Install Terraform
2. Signup on GitHub and create a github repository to store your terraform code
3. Install Git
4. Create a keypair using ssh-keygen command, add the public key to your github repo and the private key should be locally in your pc in the $HOME/.ssh dir.

5. Clone your private repo to your local pc, add your terrform code and push changes to your remote repo.
6. Install vs code
7. install the aws cli
8. create IAM user <obinna>in aws and grant it permission to call the aws API to provision resources in your aws account.
9. Create named profile using aws configure --profile "obinna"
10.create s3 bucket for the storage of the terraform state file
https://developer.hashicorp.com/terraform/language/settings/backends/s3

11. Create resources in aws and authenticate with aws by defining the provider block.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs

12. Write your terraform code.

13. Depending on your application requirements, that will depend on the resources to provision.



ISSUES:
I was prompted by OAUT to enter my github username and password for authentication b4 pushing.
I entered a diff github email and password from the repo i was pushing to.
I encountered error 403,  git push
remote: Permission to obinnaaliogor/nest-application-code.git denied to aliogorobinna.
fatal: unable to access 'https://github.com/obinnaaliogor/nest-application-code.git/': The requested URL returned error: 403

Temporary Solution: As a temporary solution, consider using Git with HTTPS URLs that include your GitHub username in the URL. For example:

bash

    git clone https://username@github.com/obinnaaliogor/nest-application-code.git

    This will prompt you for your GitHub password directly, bypassing any stored credentials.

Remember, if you're still facing difficulties and none of these solutions work, it might be helpful to reach out to GitHub Support for further assistance. Additionally, you should ensure that you are using the correct GitHub account credentials when prompted for authentication.


In creating an eip resource using terraform i noted that passing an argument vpc and it bool value "true" results in deprecated message.
Terraform recommends to use argument domain = "vpc" to avoid this msg.


Important:

the .id is needed to specify the type of attribute you are referncing
which is best practice
    security_groups = ["aws_security_group.webserver_security_group.id"] or
    security_groups = [aws_security_group.webserver_security_group.id]

I apologize for any confusion. You are correct that using `.id` is necessary when you want to reference the ID attribute of a resource in Terraform. The decision between using quotes and directly referencing the resource depends on the context and usage.

Here's the clarification:

1. **Direct Reference without Quotes**:

   If you are directly referencing the resource ID attribute, you should not use quotes and you should include the `.id` suffix. This is the correct approach:

   ```hcl
   security_groups = [aws_security_group.webserver_security_group.id]
   ```

   This approach is used when you want to pass the resource ID to another resource's attribute, for example, when associating security groups with instances.

2. **Using Quotes**:

   If you want to use a string representation of the resource's ID attribute, you should use quotes around it:

   ```hcl
   security_groups = ["aws_security_group.webserver_security_group.id"]
   ```

   However, this approach is not as common, and using direct references is usually preferred.

In most cases, the first approach (without quotes) is what you will use in your Terraform configurations. It provides clarity and direct association between resources. If you're unsure which approach to use in a specific situation, referring to the Terraform documentation or seeking guidance from the Terraform community can be helpful.


ISSUE:

2. │ Error: creating RDS DB Instance (restore from snapshot) (fleetcart-db-id): InvalidParameterCombination: DB Instance class db.t2.micro does not support encryption at rest
│       status code: 400, request id: e6e441aa-d511-42e1-b4ae-076971153889
│
│   with aws_db_instance.database_instance,
│   on rds.tf line 23, in resource "aws_db_instance" "database_instance":
│   23: resource "aws_db_instance" "database_instance" {


SOLU:
Update Terraform Configuration: In your Terraform configuration, update the instance_class attribute to use an instance class that supports encryption at rest. For


ISSUE:
╷
│ Error: attaching Auto Scaling Group (fleetcart-asg) target group (arn:aws:elasticloadbalancing:us-east-1:612500737416:loadbalancer/app/application-loadbalancer/7dd3cd9758f1f532): ValidationError: Provided Target Groups may not be valid. Please ensure they exist and try again.
│       status code: 400, request id: 2ede0282-7811-47fb-ac81-56b1a9a16bcc
│
│   with aws_autoscaling_attachment.asg_alb_target_group_attachment,
│   on asg.tf line 72, in resource "aws_autoscaling_attachment" "asg_alb_target_group_attachment":
│   72: resource "aws_autoscaling_attachment" "asg_alb_target_group_attachment" {


SOLU;
This occured because i refernced this below:

resource "aws_autoscaling_attachment" "asg_alb_target_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.id
  lb_target_group_arn    = aws_lb.application_load_balancer.arn
}
I was supposed to reference the target group arn but instead referenced the alb arn in the asg attachment.
Changing aws_lb.application_load_balancer.arn ----> aws_lb_target_group.alb_target_group.arn solved the error.


OBSERVATION:
# get the latest db snapshot
# terraform aws data db snapshot
data "aws_db_snapshot" "latest_db_snapshot" {
  db_snapshot_identifier = "arn:aws:rds:us-east-1:612500737416:snapshot:rentzone-db-v4"

   #"my-database" searching the db snapshot using the id of the snapshot couldnt get it but the arn
  most_recent            = true
  snapshot_type          = "manual"
}



ISSUE:
WHILE CREATING THE RDS FROM SNAPSHOT 2 THINGS ARE REQUIRED FROM THE SNAPSHOT.
1. SNAPSHOT IDENTIFIER WHICH IS THE ARN OF THE SNAPSHOT
2. RDS INSTANCE IDENTIFIER, WHICH IS ALSO REGARDED AS THE <Instance/Cluster Name>. This is also gotten from the rds snapshot.


OBSERVATION:
I entered the wrong name in place of the rds instance identifier while creating the rds.
I was supposed to get this from the snapshot.
This did not prevent my terraform code from running but after the resources was created, my application could not run.

I also noted that once i destroy resources, and try to create it again, some of the resources like the rds components wont be under the management of my statefile even though it was created from the statefile.

Changing the rds instance indentifier to reflect the actual rds id in my snapshot solved this problem.

App was deployed and ran successfully.
