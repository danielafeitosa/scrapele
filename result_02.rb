require "selenium-webdriver"

def parse_page(values = {})
  district = values.dig(:district)
  section = values.dig(:section)
  table = values.dig(:table)
  election = values.dig(:election)

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  driver = Selenium::WebDriver.for :chrome, options: options
  driver.navigate.to "https://www.padron.gov.ar/publica/"
  @wait.until {
    districto = driver.find_element(:id, 'site')
    districto_select = Selenium::WebDriver::Support::Select.new(districto)
    districto_select.select_by(:value, "02   ")

    election = driver.find_element(:id, 'elec')
    election_select = Selenium::WebDriver::Support::Select.new(election)
    election_select.select_by(:value, "0")


      seccion = driver.find_element(:id, 'secm')
      seccion_select = Selenium::WebDriver::Support::Select.new(seccion)
      seccion_select.select_by(:value, "#{get_section_number(section)}")


    mesa = @wait.until {
      input = driver.find_element(:id, 'mesa')
      input if input.displayed?
    }
    mesa.send_keys(table)
    driver.find_element(id: 'btnVer').click
    @wait.until { driver.find_element(:id, "cuerpo") }
    page = driver.page_source

    filename = "district2_section#{section}_mesa#{table}.txt"
    File.open(filename, 'w+') do |f|
      f.puts page
    end
    driver.quit
    sleep 3
  }
end


def get_section_number(number)
  number < 1000 ? '000' + number.to_s : number
  number < 100 ? '0000' + number.to_s : number
  number < 10 ? '0000' + number.to_s : number
end

page = ''

selected = ARGV[0]

sections = {}
seclines = File.open('tables_02').readlines
seclines.each do |l|
  content = l.split(' ')
  sections[content[0].to_i] = content[2].to_i
end
sections = if selected && sections.dig(selected.to_i)
              sections.keep_if { |key| [selected.to_i].include?(key) }
            else
              sections.reject { |key| [0, 0].include?(key) }
            end

@wait = Selenium::WebDriver::Wait.new(:timeout => 6)
i = 0

@errors = []
sections.each_pair do |section, tables|
  while i < tables do
    i += 1
    begin
      parse_page(section: section, table: i)
    rescue Exception => e
      puts "Could not find the data:\n Seccion: #{section}\n Mesa: #{i}"
      @errors << {section: section, table: i}
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
