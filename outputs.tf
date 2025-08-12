output "db_teamcity_password" {
  description = "This is the password that Teamcity should use for the 'teamcity' user connecting to the Postgres DB"
  value = random_password.db_teamcity_password.result
  sensitive = true
}
