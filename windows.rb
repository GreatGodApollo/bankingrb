=begin
Made by Brett Bender; 2017
Designed for Windows, check https://github.com/beeztem/bankingrb for the linux version
=end

# Gems Required
require 'sequel'
require 'io/console'

# Configure the gems required
DB = Sequel.connect('sqlite://files/banking.db')
cards = DB[:cards]
passes = DB[:passes]

# -- Clear the screen --
system "cls"

# -- Start Program --
while true do 
	print "Please enter your banking number: "
	idn = gets.chomp
	if idn != ""
		name = cards[UID: idn]
		if name != nil
			sleep 1
			name = cards[UID: idn][:NAME]
			epin = STDIN.getpass("Please enter your pin number: ")
			if cards[UID: idn][:PIN].to_i == epin.to_i || epin.to_i == passes[ID: 2][:pass].to_i
			system "cls"
				while true do
					bal = cards[UID: idn][:BALANCE].to_f
					puts "Hello #{cards[UID: idn][:NAME]}."
					puts "Welcome to the BBRB interface\n1 To check balance\n2 To transfer money\n3 To logout"
					print "Type choice and press enter: "
					opt = gets.chomp
					system "cls"
					if opt.to_i == 1
						puts "Your balance is $#{bal}"
					elsif opt.to_i == 2
						print "What account would you like to transfer to? (Banking Number): "
						tidn = gets.chomp
						print "How much would you like to transfer? $"
						ta = gets.chomp.to_f
						if bal - ta > 0.1 && tidn != idn
							obal = cards[UID: tidn]
							if obal != nil
								obal = cards[UID: tidn][:BALANCE].to_f
								cards.where(UID: idn).update(:balance => bal - ta)
								cards.where(UID: tidn).update(:balance => obal + ta)
								puts "$#{ta} have been transferred to #{tidn}. Your new balance is #{bal - ta}"
							end
						else
							puts "Sorry, transferring $#{ta} would put you below at or below $0, you need at least $0.01 in you account"
							sleep 3
							system "cls"
						end
					elsif opt.to_i == 3
						break
					end
				end
			elsif cards[UID: idn][:PIN].to_i != epin.to_i
				puts "The pin is wrong."
				system "cls"
			end
		elsif idn == "admin"
			pass = STDIN.getpass("Enter the admin password: ")
			if pass == passes[ID: 1][:pass]
				puts "There have been #{passes[ID: 1][:fails]} failed attempts at accessing your account."
				passes.where(ID: 1).update(:fails => 0)
				puts "1 To add money to an account\n2 To Remove money from an account\n3 To logout"
				opt = gets.chomp
					if opt.to_i == 1
						print "To what account would you like to add money? "
						opt = gets.chomp
						bbal = cards[UID: opt]
						print "How much money would you like to add? $"
						mons = gets.chomp.to_f
						pass = STDIN.getpass("Enter the admin password one final time: ")
						if pass == passes[ID: 1][:pass]
							bbal = cards[UID: opt][:BALANCE].to_f
							abal = bbal + mons
							cards.where(UID: opt).update(:balance => abal)
							puts "Account successfully updated."
							sleep 2
							system "cls"
						end
					elsif opt.to_i == 2
						print "From what account would you like to remove money? "
						opt = gets.chomp
						bbal = cards[UID: opt]
						print "How much money would you like to remove? $"
						mons = gets.chomp.to_f
						pass = STDIN.getpass("Enter the admin password one final time: ")
						if pass == passes[ID: 1][:pass]
							bbal = cards[UID: opt][:BALANCE].to_f
							if bbal - mons > 0 then abal = bbal - mons
								cards.where(UID: opt).update(:balance => abal)
								puts "Account successfully updated."
								sleep 2
								system "cls"
						end
					elsif opt.to_i == 3
						break
					end
				end
			else
				puts "You have failed at entering the admin account, this has been marked!"
				fails_before = passes[ID: 1][:fails]
				fails_after  = fails_before + 1
				passes.where(ID: 1).update(:fails => fails_after)
				sleep 1
			end
		system "cls"
		else
			sleep 1
			puts"\nSorry, this banking number is not registered, please register it."
			puts "1 to register\n2 to quit"
			print "Type choice and press enter: "
			opt = gets.chomp
			if opt.to_i == 1
				print "Enter your first and last name: "
				nname = gets.chomp
				npin = STDIN.getpass("\nPlease enter your pin number for your new account: ")
				cards.insert(UID: idn, NAME: nname, PIN: npin, BALANCE: 0.1)
				puts "Your account has been created."
				sleep 2
				system "cls"
			else
				system "cls"
			end
		end
	end
end
