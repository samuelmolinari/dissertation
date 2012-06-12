# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([
  {
    :fname => "Walter",
    :lname => "White",
    :uname => "walter_white",
    :email => "walter_white@breakingbad.com",
    :email_confirmation => "walter_white@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Skyler",
    :lname => "White",
    :uname => "skyler_white",
    :email => "skyler_white@breakingbad.com",
    :email_confirmation => "skyler_white@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Jesse",
    :lname => "Pinkman",
    :uname => "jesse_pinkman",
    :email => "jesse_pinkman@breakingbad.com",
    :email_confirmation => "jesse_pinkman@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Hank",
    :lname => "Schrader",
    :uname => "hank_schrader",
    :email => "hank_schrader@breakingbad.com",
    :email_confirmation => "hank_schrader@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Marie",
    :lname => "Schrader",
    :uname => "marie_schrader",
    :email => "marie_schrader@breakingbad.com",
    :email_confirmation => "marie_schrader@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Walter, Jr.",
    :lname => "White",
    :uname => "walter_jr_white",
    :email => "walter_jr_white@breakingbad.com",
    :email_confirmation => "walter_jr_white@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Saul",
    :lname => "Goodman",
    :uname => "saul_goodman",
    :email => "saul_goodman@breakingbad.com",
    :email_confirmation => "saul_goodman@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Mike",
    :lname => "Ehrmantraut",
    :uname => "mike_ehrmantraut",
    :email => "mike_ehrmantraut@breakingbad.com",
    :email_confirmation => "mike_ehrmantraut@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  },
  {
    :fname => "Gustavo",
    :lname => "Fring",
    :uname => "gustavo_fring",
    :email => "gustavo_fring@breakingbad.com",
    :email_confirmation => "gustavo_fring@breakingbad.com",
    :dob   => [0,0,0],
    :password => "0"
  }
])
