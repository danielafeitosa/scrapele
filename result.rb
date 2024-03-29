require "selenium-webdriver"

def parse_page(values = {})
  district = values.dig(:district)
  section = values.dig(:section)
  table = values.dig(:table)

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  driver = Selenium::WebDriver.for :chrome, options: options
  driver.navigate.to "https://www.padron.gov.ar/publica/"
  @wait.until {
    districto = driver.find_element(:id, 'site')
    districto_select = Selenium::WebDriver::Support::Select.new(districto)
    districto_select.select_by(:value, "#{get_district_number(district)}   ")

    if district == 2
      seccion = driver.find_element(:id, 'secm')
      seccion_select = Selenium::WebDriver::Support::Select.new(seccion)
      seccion_select.select_by(:value, get_section_number(section))
    end

    mesa = @wait.until {
      input = driver.find_element(:id, 'mesa')
      input if input.displayed?
    }
    mesa.send_keys(table)
    driver.find_element(id: 'btnVer').click
    @wait.until { driver.find_element(:id, "cuerpo") }
    page = driver.page_source

    filename = "district#{district}_mesa#{table}.html"
    File.open(filename, 'w+') do |f|
      f.puts page
    end
    driver.quit
    sleep 3
  }
end

def get_district_number(number)
  number < 10 ? '0' + number.to_s : number
end

def get_section_number(number)
  section = number.to_s
  length = section.size
  missing = 5 - length
  (missing * '0') + section
end

page = ''

selected = ARGV[0]

districts = {}
lines = File.open('tables_all').readlines
lines.each do |l|
  content = l.split(' ')
  districts[content[0].to_i] = content[2].to_i
end
districts = if selected && districts.dig(selected.to_i)
              districts.keep_if { |key| [selected.to_i].include?(key) }
            else
              districts.reject { |key| [1, 2].include?(key) }
            end

@wait = Selenium::WebDriver::Wait.new(:timeout => 6)
i = 0
@errors = []
districts.each_pair do |district, tables|
  while i < tables do
    i += 1
    begin
      parse_page(district: district, table: i)
    rescue Exception => e
      puts "Could not find the data:\n Districto: #{district}\n Mesa: #{i}"
      @errors << {district: district, table: i}
    end
  end
end

retry_errors = []
unless @errors.empty?
  @errors.each do |params|
    begin
      puts "Retyring #{params}"
      parse_page(params)
    rescue Exception => e
      puts "  Could not find the data"
      retry_errors << params
    end
  end
end

unless retry_errors.empty?
  puts "We could not get these data:"
  retry_errors.each do |error|
    puts error
  end
end
