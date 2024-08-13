resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        name = "terraform-101"
    }
}
    #provider.tf 랑 묶어서 사용 가능 물론 서브넷도 별도로 subnet.tf 등의 파일로 구성 가능
resource "aws_subnet" "public_subnet" {
    # main 으로 이름지었던 vpc의 id를 따라감 없으면 arn 사용해서 박아넣으면 될듯
    vpc_id = aws_vpc.main.id
    cidr_block ="10.0.0.0/24"
    # 가용영역 설정 (선택사항)
    # 명시를 안하면 아무대나 만들어짐
    availability_zone = "ap-northeast-2a"

    tags = {
        name = "terraform-101-public-subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block ="10.0.10.0/24"

    tags = {
        name = "terraform-101-private-subnet"
    }
}

### internet_gateway ###
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    
    tags = {
        name = "terraform-101-igw"
    }
}

### eip and nat_gateway ###
resource "aws_eip" "nat" {
    domain = "vpc"
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat.id

    subnet_id = aws_subnet.public_subnet.id
    
    tags = {
        name = "terraform-101-nat-gateway"
    }
}
### Route Table (public) ###
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
# 방법 1 라우팅 테이블 리소스 생성 내에서 작성
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        name = "terraform-101-public-route"
    }
}

resource "aws_route_table_association" "route_table_association_public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public.id
}

### Route Table (private) ###
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
   
    tags = {
        name = "terraform-101-private-route"
    }
}

resource "aws_route_table_association" "route_table_association_private" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private.id
}
#방법 2 resorce "aws_route" 를 통해서 외부에서 라우트 생성
#실제 작동은 차이가 없으나 코드의 생김세가 달라짐
#확장성을 생각한다면 안에서 만드는것보단 외부로 빼는게 좋음

resource "aws_route" "private_nat" {
  route_table_id              = aws_route_table.private.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_gateway.id
}

#테라폼의 강점
#plan,apply 를 시행했을때 미리 생성된 리소스를 검사
#누가 콘솔을 통해서 수정했을경우 내가 원하는 형상내로 다시 복구가 가능함