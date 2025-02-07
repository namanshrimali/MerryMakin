flutter clean && flutter build web --web-renderer canvaskit --release 
rm -rf /Users/namanshrimali/development/personal_projects/moneymoney-service/src/main/resources/static/*
cp -R build/web/ /Users/namanshrimali/development/personal_projects/moneymoney-service/src/main/resources/static
