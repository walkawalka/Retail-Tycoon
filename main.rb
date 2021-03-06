require_relative 'lib/inventory'

inventory = Inventory.new

money = 100

def format_money(number)
  "$" + number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

puts ""
puts "Welcome, entrepreneur! You have #{format_money(money)}. Below is a list of your starting inventory:"
puts ""
inventory.print

loop do
  puts ""
  puts "What do you want to do? You have #{format_money(money)}. (For list of commands, type '(h)elp')"
  command = gets.chomp
  puts ""

  if command[0] == 'h'
    puts "'(h)elp' lists avaliable commands"
    puts "'(l)ist' lists everything in your store inventory"
    puts "'(u)pdate' lets you update inventory prices"
    puts "'(i)nspect' allows you to see more details about a specific style"
    puts "'(d)esign' allows you to design a new style"
    puts "'(o)pen' opens the shop and allows customers in"
  elsif command[0] == 'l'
    inventory.print
  elsif command[0] == 'u'
    puts inventory.list

    begin
      continue = false

      begin
        puts ""
        puts "Type the style number of the item for which you wish to update the pricing."
        style_num = gets.chomp

        batch = inventory.lookup(style_num)
      end while batch.nil?

      puts ""
      puts "What price do you want the #{batch.style.to_s} to be?"
      puts "Cost to produce: #{batch.style.cost}"
      batch.style.price = gets.chomp

      puts ""
      puts "The #{batch.style.to_s} is now priced at #{batch.style.price}."
      puts ""
      puts "Would you like to update another price? (Yn) (type 'list' to print inventory list)"
      command = gets
      if command.chomp.upcase == 'Y' or command == "\n"
        continue = true
      elsif command.chomp[0] == 'l'
        puts
        puts inventory.list
        puts "\nWould you like to update another price? (Yn)"
        command = gets
        if command.chomp.upcase == 'Y' or command == "\n"
          continue = true
        end
      end
    end while continue
  elsif command[0] == 'i'
    puts "Enter the style number of the item you wish to inspect"
    style_num = gets.chomp

    batch = inventory.lookup(style_num)

    puts "#{batch.style.inspect_style}"
  elsif command[0] == 'd'
    puts "Type in what type of item you wish to design. Types are listed below"
    puts Style.types
    new_style_type = gets.chomp
    puts "\nType in what kind of fabric the #{new_style_type} will be."
    puts Style.fabric_types
    new_style_fabric = gets.chomp
    puts "\nType in what color the #{new_style_fabric} #{new_style_type} will be."
    puts Style.colors
    new_style_color = gets.chomp
    puts "\nYou have designed a #{new_style_color} #{new_style_fabric} #{new_style_type}."
    puts "Is this correct? (Yn)"
    command = gets
    if command.chomp == 'n'
      begin
        continue = true
        puts "Indicate what part is wrong: (t)ype, (f)abric, or (c)olor"
        command = gets.chomp
        if command == 't'
          puts "Type in what type of item you wish to design. Types are listed below"
          puts Style.types
          new_style_type = gets.chomp
        elsif command == 'f'
          puts "\nType in what kind of fabric the #{new_style_type} will be."
          puts Style.fabric_types
          new_style_fabric = gets.chomp
        elsif command == 'c'
          puts "\nType in what color the #{new_style_fabric} #{new_style_type} will be."
          puts Style.colors
          new_style_color = gets.chomp
        end
        puts "\nYou have designed a #{new_style_color} #{new_style_fabric} #{new_style_type}."
        puts "Is this correct? (Yn)"
        command = gets
        if command.chomp == 'y' or command == "\n"
          continue = false
        end
      end while continue #end of fixing new design problems loop
    end
    puts "\nDefault items to be made is 8, which will cost: #{format_money(Style.cost_calc(new_style_type, new_style_fabric) * 8)}."
    puts "What price do you want to put to your new style?"
    inventory.add_style(new_style_type, new_style_fabric, new_style_color, gets.to_i)
    batch = inventory.batches.last
    puts batch.style.cost.inspect
    money -= batch.style.cost * batch.quantities.values.reduce(:+)
  elsif command[0] == 'o'
    puts "\nHow many hours do you want your shop open for?"
    hours = gets.to_i * 15
    puts ""
    hours.times do |time|
      if Random.new.rand(100) < 16
        Thread.new do
          puts "Customer comes in"
          sleep 5

          batch = inventory.batches.sample
          batch.quantities["M"] -= 1
          money += batch.style.price
          puts "Customer bought #{batch.style.sales_tag}. You have #{format_money(money)}"
        end
      end

      sleep 1
    end
    puts "Customers could still be in the store. Wait for them to finish"
    sleep 5
  end #end of command options
end #end of command-asking loop
