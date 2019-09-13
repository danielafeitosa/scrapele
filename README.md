# scrapele
Scrap for https://www.padron.gov.ar/publica/

Requirements (Windows):
- Chrome https://www.google.com/intl/es-419/chrome/
- Ruby https://rubyinstaller.org/downloads/
- Java https://www.java.com/es/download/
- Selenium Standalone Server https://www.seleniumhq.org/download/
- Selenium - Webdriver https://rubygems.org/gems/selenium-webdriver
- ChromeDriver - WebDriver for Chrome https://sites.google.com/a/chromium.org/chromedriver/downloads

Start Selenium Server with command prompt:

java -jar selenium-server-standalone.jar

Put chromedriver.exe in C:\Windows\System32\

Syntax:

In Ruby command prompt, type:

result.rb X

Where X is district number in tables_all and district > 2.

If no parameter given, it will scrap all districts > 2.

For HTML parsing, we will use nokogiri (To Do)
