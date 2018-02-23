resource "aws_key_pair" "myaccount" {
  key_name   = "myaccount-key"
  public_key = "${file("myaccount.pub")}"
}
