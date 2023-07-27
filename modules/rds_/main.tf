# create the subnet group for the rds instance
resource "aws_db_subnet_group" "rds_sg" {
  count        = var.rds_instances_count
  name         = "opsschool-project-db-subnet-${count.index}"
  subnet_ids   = var.private_data_subnet_id
  description  = "subnet group for db instances"

  tags   = {
    Name = "opsschool-project-db-sg-${count.index}"
  }
}


# create the rds instance
resource "aws_db_instance" "rds" {
  count                   = var.rds_instances_count
  engine                  = "postgres"
  engine_version          = "14.7"
  multi_az                = false
  identifier              = "rds-db-instance-${count.index}"
  storage_type            = "io1"
  iops                    = 3000
  username                = "diana"
  password                = "Aa123456!"
  instance_class          = "db.t3.micro"
  allocated_storage       = 50
  max_allocated_storage   = 200
  db_subnet_group_name    = aws_db_subnet_group.rds_sg[count.index].name
  vpc_security_group_ids  = [var.bastion_ssh_from_security_group_id, aws_security_group.rds_sg.id]
  db_name                 = "postgres"
  skip_final_snapshot     = true
  availability_zone       = var.availability_zones_names[count.index]
  
  tags   = {
    Name     = "os-project-PostgreSQL-${count.index}"
    OSType   = "db"
    Service  = "PostgreSQL"
    Type     = "server"
    Stop     = "false"
  }
}


# create private security group
resource "aws_security_group" "rds_sg" {
  name        = "Database security group"
  description = "Dont enable internet access"
  vpc_id      = var.vpc_id

  ingress {
    description      = "PostgreSQL Access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "TCP"   
    cidr_blocks      = [var.vpc_cidr_range]
  }

  ingress {
    description        = "Elasticsearch Java interface"
    from_port          = 9300
    to_port            = 9300
    protocol           = "TCP"
    security_groups    = [var.logging_sg]
  }
  
  ingress {
    description        = "Elasticsearch REST interface"
    from_port          = 9200
    to_port            = 9200
    protocol           = "TCP"
    security_groups    = [var.logging_sg]
  }

  tags   = {
    Name     = "opsschool-project-DB-SG"
  }
}
