output "db_secret_arn" {
	value = aws_secretsmanager_secret.db_master_secret_new.arn
	description = "arn of secret that holds db creds"
}