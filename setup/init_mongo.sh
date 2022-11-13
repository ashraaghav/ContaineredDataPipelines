set -e

# create database & users using .sh because it is just easier!
mongosh -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" <<EOF
use datastore
db.tmp_collection.insertOne({tmp: "tmp"})  // creating a collection to actually create the DB

db.createUser({
  user:'analyst',
  pwd:'ana_pass1',
  roles: [{role:'readWrite', db: 'datastore'}]
})
EOF
