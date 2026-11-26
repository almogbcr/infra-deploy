dev = {
  env            = "dev"
  vpc_cidr       = "10.0.0.0/20"
  subnet_private = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_public  = ["10.0.2.0/24", "10.0.3.0/24"]
}

prod = {
  env            = "prod"
  vpc_cidr       = "10.0.16.0/20"
  subnet_private = ["10.0.16.0/24", "10.0.17.0/24"]
  subnet_public  = ["10.0.18.0/24", "10.0.19.0/24"]
}