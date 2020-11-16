resource "aws_elastic_beanstalk_application" "beanstalk" {
  name        = "beanstalk-app"
  description = "beanstalk-app"
}

resource "aws_elastic_beanstalk_environment" "beanstalk-staging" {
  name                = "beanstalk-staging"
  application         = aws_elastic_beanstalk_application.beanstalk.name
  solution_stack_name = "64bit Windows Server 2019 v2.5.11 running IIS 10.0"
  cname_prefix = "beanstalk-staging"
  wait_for_ready_timeout  = "45m"

  /*
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "" #"${aws_vpc.main.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "" #"${aws_subnet.main-private-1.id},${aws_subnet.main-private-2.id}"
  }
  */
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "false"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "BeanstalkInstanceProfile"
  }
  /*
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "" #"${aws_security_group.app-prod.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "" #"${aws_key_pair.app.id}"
  }
  */
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "aws-elasticbeanstalk-service-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBScheme"
    value = "public"
  }
  /*
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "" #"${aws_subnet.main-public-1.id},${aws_subnet.main-public-2.id}"
  }
  */
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "30"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Percentage"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }
  /*
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_USERNAME"
    value = "" #"${aws_db_instance.rds-app-prod.username}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PASSWORD"
    value = "" #"${aws_db_instance.rds-app-prod.password}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_DATABASE"
    value = "" #"${aws_db_instance.rds-app-prod.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_HOSTNAME"
    value = "" #"${aws_db_instance.rds-app-prod.endpoint}"
  }
  */
}

#####
# Instance Profile
#####

resource "aws_iam_instance_profile" "BeanstalkInstanceProfile" {
  name = "BeanstalkInstanceProfile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}