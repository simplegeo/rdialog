#                                vim:ts=4:sw=4:
# = rdialog - A dialog gem for Ruby
#
# Homepage::  http://built-it.net/ruby/rdialog/
# Author::    Aleks Clark (http://built-it.net)
# Copyright:: (cc) 2004 Aleks Clark
# License::   BSD
#
# class RDialog::Dialog.new( array, str, array)

require 'tempfile'
require 'date'
class RDialog 
	#
	# All accessors are boolean unless otherwise noted.
	#
	
	#
	# This gives you some control over the box dimensions when 
	# using auto sizing (specifying 0 for height and width). 
	# It represents width / height. The default is 9, 
	# which means 9 characters wide to every 1 line high.
	#
	attr_accessor :aspect
	
	#
	# Specifies a backtitle string to be displayed on the backdrop, 
	# at the top of the screen.
	#
	attr_accessor :backtitle
	
	#
	# Sound the audible alarm each time the screen is refreshed.
	#
	attr_accessor :beep
	
	#
	# Specify the position of the upper left corner of a dialog box
	# on the screen, as an array containing two integers.
	#
	attr_accessor :begin
	
	#
	# Interpret embedded newlines in the dialog text as a newline 
	# on the screen. Otherwise, dialog will only wrap lines where 
	# needed to fit inside the text box. Even though you can control 
	# line breaks with this, dialog will still wrap any lines that are 
	# too long for the width of the box. Without cr-wrap, the layout
	# of your text may be formatted to look nice in the source code of 
	# your script without affecting the way it will look in the dialog.
	#
	attr_accessor :crwrap
	
	#
	# Interpret the tags data for checklist, radiolist and menuboxes 
	# adding a column which is displayed in the bottom line of the 
	# screen, for the currently selected item.
	#
	attr_accessor :itemhelp

	#
	# Suppress the "Cancel" button in checklist, inputbox and menubox 
	# modes. A script can still test if the user pressed the ESC key to 
	# cancel to quit.
	#
	attr_accessor :nocancel
	
	#
	# Draw a shadow to the right and bottom of each dialog box.
	# 
	attr_accessor :shadow
	
	#
	# Sleep (delay) for the given integer of seconds after processing 
	# a dialog box.
	#
	attr_accessor :sleep
	
	#
	# Convert each tab character to one or more spaces. 
	# Otherwise, tabs are rendered according to the curses library's 
	# interpretation.
	#
	attr_accessor :tabcorrect
	
	#
	# Specify the number(int) of spaces that a tab character occupies 
	# if the tabcorrect option is set true. The default is 8.
	#
	attr_accessor :tablen
	
	#
	# Title string to be displayed at the top of the dialog box.
	#
	attr_accessor :title
	
	#
	# Alternate path to dialog. If this is not set, environment path
	# is used.
	attr_accessor :path_to_dialog

	# Returns a new RDialog Object

	def initialize()
	end
        #      A calendar box displays  month,  day  and  year  in  separately
        #      adjustable  windows.   If the values for day, month or year are
	#      missing or negative, the current  date's  corresponding  values
        #      are  used.   You  can increment or decrement any of those using
        #      the left-, up-, right- and down-arrows.  Use vi-style h,  j,  k
        #      and  l for moving around the array of days in a month.  Use tab
        #      or backtab to move between windows.  If the year  is  given  as
        #      zero, the current date is used as an initial value.
	#
	#	Returns a Date object with the selected date

	def calendar(text="Select a Date", height=0, width=0, day=Date.today.mday(), month=Date.today.mon(), year=Date.today.year())

		tmp = Tempfile.new('tmp')

		command = option_string() + "--calendar \"" + text.to_s + 
			"\" " + height.to_i.to_s + " " + width.to_i.to_s + " " + 
			day.to_i.to_s + " " + month.to_i.to_s + " " + year.to_i.to_s + 
			" 2> " + tmp.path
		success = system(command)
		if success
			date = Date::civil(*tmp.readline.split('/').collect {|i| i.to_i}.reverse)
			tmp.close!
			return date
		else
			tmp.close!
			return success
		end	
		
	end

	#      A  checklist  box  is similar to a menu box; there are multiple
        #      entries presented in the form of a menu.  Instead  of  choosing
        #      one entry among the entries, each entry can be turned on or off
        #      by the user.  The initial on/off state of each entry is  speci-
        #      fied by status.

	def checklist(text, items, height=0, width=0, listheight=0)
		
		tmp = Tempfile.new('tmp')

		itemlist = String.new

		for item in items
			if item[2]
				item[2] = "on"
			else
				item[2] = "off"
			end
			itemlist += "\"" + item[0].to_s + "\" \"" + item[1].to_s + 
			"\" " + item[2] + " "

			if @itemhelp
				itemlist += "\"" + item[3].to_s + "\" "
			end
		end

		command = option_string() + "--checklist \"" + text.to_s +
                        "\" " + height.to_i.to_s + " " + width.to_i.to_s +
			" " + listheight.to_i.to_s + " " + itemlist + "2> " +
			tmp.path 
		puts command
		success = system(command)
		puts success
		if success && tmp.size > 0
			selected_string = tmp.readline
			tmp.close!
			selected_string.slice!(0)
			selected_string.chomp!("\"")
			selected_array = selected_string.split('" "')
			for item in selected_array
				item.delete!("\\")
			end

			return selected_array
		else
			tmp.close!
			return success
		end

	end

        #      The file-selection dialog displays a text-entry window in which
        #      you can type a filename (or directory), and above that two win-
        #      dows with directory names and filenames.

        #      Here  filepath  can  be  a  filepath in which case the file and
        #      directory windows will display the contents of the path and the
        #      text-entry window will contain the preselected filename.
	#
        #      Use  tab or arrow keys to move between the windows.  Within the
        #      directory or filename windows, use the up/down  arrow  keys  to
        #      scroll  the  current  selection.  Use the space-bar to copy the
        #      current selection into the text-entry window.
	#
        #      Typing any printable characters switches  focus  to  the  text-
        #      entry  window, entering that character as well as scrolling the
        #      directory and filename windows to the closest match.
	#
        #      Use a carriage return or the "OK" button to accept the  current
        #      value in the text-entry window and exit.

	def fselect(path, height=0, width=0)
                tmp = Tempfile.new('tmp')

                command = option_string() + "--fselect \"" + path.to_s +
                "\" " + height.to_i.to_s + " " + width.to_i.to_s + " "

                command += "2> " + tmp.path

                success = system(command)

                if success
                        begin
                                selected_string = tmp.readline
                        rescue EOFError
                                selected_string = ""
                        end
                        tmp.close!
                        return selected_string
                else
                        tmp.close!
                        return success
                end
	end
	# Does not work. Someone is welcome to try and make it work.
	def gauge(text, height=0, width=0)
		return false
	end

        #      An info box is basically a message box.  However, in this case,
        #      dialog  will  exit  immediately after displaying the message to
        #      the user.  The screen is not cleared when dialog exits, so that
        #      the  message  will remain on the screen until the calling shell
        #      script clears it later.  This is useful when you want to inform
        #      the  user that some operations are carrying on that may require
        #      some time to finish.
	#
	#      Returns false if esc was pushed

	def infobox(text, height=0, width=0)
		command = option_string() + "--infobox \"" + text.to_s +
                "\" " + height.to_i.to_s + " " + width.to_i.to_s + " "
		success = system(command)
		return success
	end

        #      A  radiolist box is similar to a menu box.  The only difference
        #      is that you can indicate which entry is currently selected,  by
        #      setting its status to true.

        def radiolist(text, items, height=0, width=0, listheight=0)

                tmp = Tempfile.new('tmp')

                itemlist = String.new

                for item in items
                        if item[2]
                                item[2] = "on"
                        else
                                item[2] = "off"
                        end
                        itemlist += "\"" + item[0].to_s + "\" \"" + item[1].to_s +
                        "\" " + item[2] + " "

                        if @itemhelp
                                itemlist += "\"" + item[3].to_s + "\" "
                        end
                end

                command = option_string() + "--radiolist \"" + text.to_s +
                        "\" " + height.to_i.to_s + " " + width.to_i.to_s +
                        " " + listheight.to_i.to_s + " " + itemlist + "2> " +
                        tmp.path
                success = system(command)

                if success
        	        selected_string = tmp.readline
               		tmp.close!
                        return selected_string
                else
			tmp.close!
                        return success
                end

	end

        #      As  its  name  suggests, a menu box is a dialog box that can be
        #      used to present a list of choices in the form of a menu for the
        #      user  to  choose.   Choices  are  displayed in the order given.
        #      Each menu entry consists of a tag string and  an  item  string.
        #      The tag gives the entry a name to distinguish it from the other
        #      entries in the menu.  The item is a short  description  of  the
        #      option  that  the  entry represents.  The user can move between
        #      the menu entries by pressing the cursor keys, the first  letter
        #      of  the  tag  as  a  hot-key, or the number keys 1-9. There are
        #      menu-height entries displayed in the menu at one time, but  the
        #      menu will be scrolled if there are more entries than that.
	#
        #      Returns a string containing the tag of the chosen menu entry.

	def menu(text="Text Goes Here", items=nil, height=0, width=0, listheight=0)
                tmp = Tempfile.new('tmp')

                itemlist = String.new

                for item in items
                        itemlist += "\"" + item[0].to_s + "\" \"" + item[1].to_s +  "\" "

                        if @itemhelp
                                itemlist += "\"" + item[2].to_s + "\" "
                        end
                end

                command = option_string() + "--menu \"" + text.to_s +
                        "\" " + height.to_i.to_s + " " + width.to_i.to_s +
                        " " + listheight.to_i.to_s + " " + itemlist + "2> " +
                        tmp.path
                success = system(command)

                if success
                        selected_string = tmp.readline
                        tmp.close!
                        return selected_string
                else
                        tmp.close!
                        return success
                end
		
	end

        #      A message box is very similar to a yes/no box.  The  only  dif-
        #      ference  between  a message box and a yes/no box is that a mes-
        #      sage box has only a single OK button.  You can use this  dialog
        #      box  to  display  any message you like.  After reading the mes-
        #      sage, the user can press the ENTER key so that dialog will exit
        #      and the calling shell script can continue its operation.

	def msgbox(text="Text Goes Here", height=0, width=0)
		command = option_string() + "--msgbox \"" + text.to_s +
                "\" " + height.to_i.to_s + " " + width.to_i.to_s + " "

		success = system(command)
		return success
	end

        #      A password box is similar to an input box, except that the text
        #      the user enters is not displayed.  This is useful when  prompt-
        #      ing  for  passwords  or  other sensitive information.  Be aware
        #      that if anything is passed in "init", it will be visible in the
        #      system's  process  table  to casual snoopers.  Also, it is very
        #      confusing to the user to provide them with a  default  password
        #      they  cannot  see.   For  these reasons, using "init" is highly
        #      discouraged.

	def passwordbox(text="Please enter some text", height=0, width=0, init="")
                tmp = Tempfile.new('tmp')
                command = option_string() + "--passwordbox \"" + text.to_s +
                "\" " + height.to_i.to_s + " " + width.to_i.to_s + " "

                unless init.empty?
                        command += init.to_s + " "
                end

                command += "2> " + tmp.path

                success = system(command)

                if success
                        begin
                                selected_string = tmp.readline
                        rescue EOFError
                                selected_string = ""
                        end
                        tmp.close!
                        return selected_string
                else
                        tmp.close!
                        return success
                end
        end

	#     The textbox method handles three similar dialog functions, textbox,
	#     tailbox, and tailboxbg. They are activated by setting type to
	#     "text", "tail", and "bg" respectively
	#
	#     Textbox mode:
	#	A  text  box  lets you display the contents of a text file in a
	#	dialog box.  It is like a simple text file  viewer.   The  user
	#	can  move  through  the file by using the cursor, PGUP/PGDN and
	#	HOME/END keys available on most keyboards.  If  the  lines  are
	#	too long to be displayed in the box, the LEFT/RIGHT keys can be
	#	used to scroll the text region horizontally.  You may also  use
	#	vi-style  keys h, j, k, l in place of the cursor keys, and B or
	#	N in place of the pageup/pagedown keys.  Scroll  up/down  using
	#	vi-style  'k'  and 'j', or arrow-keys.  Scroll left/right using
	#	vi-style  'h'  and  'l',  or  arrow-keys.   A  '0'  resets  the
	#	left/right  scrolling.   For more convenience, vi-style forward
	#	and backward searching functions are also provided.
	#
	#     Tailbox mode:
	#	Display text from a file in a dialog box, as  in  a  "tail  -f"
	#	command.   Scroll  left/right  using  vi-style  'h' and 'l', or
	#	arrow-keys.  A '0' resets the scrolling.
	#
	#     Tailboxbg mode:
	#	Display text from a file in a dialog box as a background  task,
	#	as  in a "tail -f &" command.  Scroll left/right using vi-style
	#	'h' and 'l', or arrow-keys.  A '0' resets the scrolling.

	def textbox(file, type="text", height=0, width=0)
		case type
			when "text"
				opt = "--textbox"
			when "tail"
				opt = "--tailbox"
			when "bg"
				opt = "--textboxbg"
		end

		command = option_string() + opt +" \"" + file.to_s +
                "\" " + height.to_i.to_s + " " + width.to_i.to_s + " "
		
		success = system(command)

		return success
	end

        #      A dialog is displayed which allows you to select  hour,  minute
        #      and second.  If the values for hour, minute or second are miss-
        #      ing or negative, the current date's  corresponding  values  are
        #      used.   You  can  increment or decrement any of those using the
        #      left-, up-, right- and down-arrows.  Use tab or backtab to move
        #      between windows.
	#
        #      On  exit, a Time object is returned.

	def timebox(file, type="text", height=0, width=0, time=Time.now)
               tmp = Tempfile.new('tmp')

                command = option_string() + "--timebox \"" + text.to_s +
                        "\" " + height.to_i.to_s + " " + width.to_i.to_s + " " +
			time.hour.to_s + " " + time.min.to_s + " " + 
			time.sec.to_s + " 2> " + tmp.path
                success = system(command)
                if success
                        time = Time.parse(tmp.readline)
                        tmp.close!
                        return time
                else
                        tmp.close!
                        return success
                end
		
	end

        #      An input box is useful when you  want  to  ask  questions  that
        #      require  the  user to input a string as the answer.  If init is
        #      supplied it is used  to  initialize  the  input  string.   When
        #      entering  the string, the backspace, delete and cursor keys can
        #      be used to correct typing  errors.   If  the  input  string  is
        #      longer  than can fit in the dialog box, the input field will be
        #      scrolled.
	#
        #      On exit, the input string will be returned.


	def inputbox(text="Please enter some text", height=0, width=0, init="")
		tmp = Tempfile.new('tmp')

		command = option_string() + "--inputbox \"" + text.to_s +
		"\" " + height.to_i.to_s + " " + width.to_i.to_s + " "

		unless init.empty?
			command += init.to_s + " "
		end

		command += "2> " + tmp.path

                success = system(command)

                if success
			begin
                        	selected_string = tmp.readline
			rescue EOFError
				selected_string = ""
			end
			tmp.close!			
                        return selected_string
                else
                        tmp.close!
                        return success
                end
	end

        #      A yes/no dialog box of size height rows by width  columns  will
        #      be displayed.  The string specified by text is displayed inside
        #      the dialog box.  If this string is too long to fit in one line,
        #      it  will be automatically divided into multiple lines at appro-
        #      priate places.  The text string can also contain the sub-string
        #      "\n"  or  newline  characters  '\n'  to  control  line breaking
        #      explicitly.  This dialog box is  useful  for  asking  questions
        #      that  require  the user to answer either yes or no.  The dialog
        #      box has a Yes button and a No button, in  which  the  user  can
        #      switch between by pressing the TAB key.

	def yesno(text="Please enter some text", height=0, width=0)
		command = option_string() + "--inputbox \"" + text.to_s +
                "\" " + height.to_i.to_s + " " + width.to_i.to_s

		success = system(command)
		return success
	end

	private	

	def option_string()
		unless @path_to_dialog
			ostring = "dialog "
		else
			ostring = @path_to_dialog + " "
		end
		if @aspect
			ostring += "--aspect " + aspect + " "
		end
		
		if @beep
			ostring += "--beep "
		end
		
		if @boxbegin 
			ostring += "--begin " + @boxbegin[0] + @boxbegin[1] + " "
		end

		if @backtitle
			ostring += "--backtitle \"" + @backtitle + "\" "
		end 

		if @itemhelp
			ostring += "--item-help "
		end

		unless @shadow == nil
			if @shadow == true
				ostring += "--shadow "
			else 
				ostring += "--no-shadow "
			end
		end

		if @sleep
			ostring += "--sleep " + @sleep.to_i + " "
		end

		if @tabcorrect
			ostring += "--tab-correct "
		end

		if @tablen
			ostring += "--tab-len " + @tablen.to_i + " "
		end

		if @title
			ostring += "--title " + @title.to_s + " "
		end

		if @nocancel
			ostring += "--nocancel "
		end

		return ostring

	end
end



#Dir[File.join(File.dirname(__FILE__), 'rdialog/**/*.rb')].sort.each { |lib| require lib }
