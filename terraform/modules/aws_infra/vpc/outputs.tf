output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "sg_id" {
    value = aws_security_group.vpc_sg.id
}

output "private_subnet_1_id" {
    value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
    value = aws_subnet.private_subnet_2.id
}

output "public_subnet_1_id" {
    value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
    value = aws_subnet.public_subnet_2.id
}

output "nat_gateway_id" {
    value = aws_nat_gateway.nat_gateway.id
}

output "public_route_id" {
    value = aws_route.public_route.id
}

output "private_route_id" {
    value = aws_route.private_route.id
}

output "public_rta_1_id" {
    value = aws_route_table_association.public_rta_1.id
}

output "public_rta_2_id" {
    value = aws_route_table_association.public_rta_2.id
}

output "private_rta_1_id" {
    value = aws_route_table_association.private_rta_1.id
}

output "private_rta_2_id" {
    value = aws_route_table_association.private_rta_2.id
}

