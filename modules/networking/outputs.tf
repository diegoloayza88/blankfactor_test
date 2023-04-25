output "vpc" {
  description = "The VPC created for the stack"

  value = {
    id   = aws_vpc.test_bf_vpc.id
    cidr = aws_vpc.test_bf_vpc.cidr_block
    arn  = aws_vpc.test_bf_vpc.arn
    azs  = var.azs

    private_subnets = {
      ids             = values(aws_subnet.private)[*].id
      arns            = values(aws_subnet.private)[*].arn
      cidr            = values(aws_subnet.private)[*].cidr_block
      route_table_ids = values(aws_route_table.private)[*].id
    }
    public_subnets = {
      ids             = values(aws_subnet.public)[*].id
      arns            = values(aws_subnet.public)[*].arn
      cidr            = values(aws_subnet.public)[*].cidr_block
      route_table_ids = values(aws_route_table.public)[*].id
    }
  }
}