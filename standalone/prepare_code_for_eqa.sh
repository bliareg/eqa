#!/bin/bash

rake tmp:clear
rm -rf ../eqa/
mkdir ../eqa
rsync -av . ../eqa --exclude \.git/ --exclude \spec/ --exclude \.rspec

cd ../eqa/

rm log/*.log

sed -i '/ADMIN_EMAIL/d' db/seeds.rb
sed -i '/superadmin\: true/d' db/seeds.rb
sed -i '/ADMIN_PASSWORD/d' db/seeds.rb

sed -i 's/quality_dashboard/eqa/g' standalone/eqa_encode_files

~/myruby/rubyencoder-2.3.0-evaluation/bin/rubyencoder --ruby 2.3 --rails @/home/ivik/myruby/eqa/standalone/eqa_encode_files -b-

git init
git add .
git commit -m "New version commit"
git remote add origin https://github.com/thinkmobiles/eqa.git
git push -u origin master
