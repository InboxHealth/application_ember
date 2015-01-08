source "https://supermarket.getchef.com"

metadata

cookbook "application"

group :test do
  cookbook "minitest-handler"
  cookbook "application_ember_test", path: "./test/cookbooks/application_ember_test"
  cookbook "nodejs"
  cookbook "user"
end