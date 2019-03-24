cd `dirname $0`
cd ../

mkdir -p ruby/lib/
cp -rfp app *.rb ruby/lib

zip -r pr_slack_notifier ruby

rm -rf ruby
