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


