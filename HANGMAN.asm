.data
	WordToGuess: .asciiz "frankenstein"	#WordToGuess with a default word
	HiddenWord : .space 30		#This is the underscore thing
	Guesses: .word 6		#Number of guesses
	CharBuffer: .space 2		#This is the space for their single character input
	WordBuffer: .space 30		#This is the space for their single character input
	PreviousGuesses: .space 26	#This is a list of all the prveious guesses
	
	Underscore: .asciiz "_"
	NewLine: .asciiz "\n"
	No : .asciiz "n"
	Goodbye: .asciiz "\nGoodbye"
	ShowWord: .asciiz "\nThe word was "
	EnterWord: "\nWould you like to enter a word to guess? (Type word or n for default) >"
	Prompt: .asciiz "Please enter a single letter to guess >"
	GameOver: .asciiz "\nGuesses depleted. You lost. Try again? (y or n) >"
	GameWin: .asciiz "\nCongradilidiationz, you winnered. Would you like to play again? (y or n) >"
	Found: .asciiz " occurences found!\n"
	NotFound: .asciiz "\nNo occurences found. You lose a body part. :(\n"
	Draw6: .asciiz "_____\n|   |\n|    \n|    \n|    \n|_____\n"
	Draw5: .asciiz "_____\n|   |\n|   O\n|    \n|    \n|_____\n"
	Draw4: .asciiz "_____\n|   |\n|   O\n|   |\n|    \n|_____\n"
	Draw3: .asciiz "_____\n|   |\n|   O\n|  /|\n|    \n|_____\n"
	Draw2: .asciiz "_____\n|   |\n|   O\n|  /|\\\n|   \n|_____\n"
	Draw1: .asciiz "_____\n|   |\n|   O\n|  /|\\\n|  /\n|_____\n"
	Draw0: .asciiz "_____\n|   |\n|   O\n|  /|\\\n|  / \\\n|_____\n"
.text
main:
	jal readwordtoguess
	li $t0, 6
	sw $t0, Guesses
gameloop:
	la $t0, Guesses			#Get the address of how many guesses are left
	lw $t0, ($t0)			#Get the value   of how many guesses are left
	beqz $t0, gamelose		#If they have no more guesses left, go tell them they failed horribly
	jal draw				#Show them what the victim looks like for tension to be formed
	jal printhiddenword		#Show them whatever progress they have made, Because it will never be enough to impress me
	la $a0, Prompt			#Tell them to enter their letter, not like it matters
	jal printstr 			#Force them to do it or they don't get any candy
	jal readletter			#Othewise, let them have their fun and put another lettter in
	beqz $v0, failureguess	#If they got no occurences, make them cry
	add $a0, $v0, $zero 	#Set the noomber into a place to print it
	jal printint			#Show them how many they got right
	la $a0, Found			#Finishing telling them how cool they are jk
	jal printstr			#Whatever
	la $a0, NewLine			#Print a newline after their character
	li $v0, 4				#Make Syscall ready for a string
	syscall					#print whatever is in a0
	jal checkwin			#See if they happened to win this meaningless game
	j gameloop				#See if we can get them to lose again
failureguess:
	la $t0, Guesses		#Get the address of how many guesses are left
	lw $t0, ($t0)		#Get the value   of how many guesses are left
	addi $t0, $t0, -1	#Remove a life HAHAHHAHAHAHA
	sw $t0, Guesses
	la $a0, NotFound	#Tell them that there were no occurences
	jal printstr		#Make it hurt
	j gameloop			#Go back and see if they can win (unlikely)

exit:	#Leave this as top Function in case it is not called and we reach the end of the main... somehow
	la $a0, Goodbye	#Load Goodbye message
	jal printstr	#Print Goodbye message
	li $v0, 10		#Load Sudoku
	syscall			#Commit Sudoku
	
printstr:
	li $v0, 4	#Make Syscall ready for a string
	syscall		#print whatever is in a0
	j return	#return to whence thy came
	
printint:
	li $v0, 1	#make Syscall ready for a int
	syscall		#print whatever is in a0
	j return	#return to whence thy came

##########START readletter
readletter:				#This will read one letter from the user
	la $a0, CharBuffer	#Get Space for an itity bitty word
	li $a1, 2			#Tell the computer it's an small itty bitty word
	li $v0, 8			#Prepare the computer to get a itty bitty word
	syscall				#Get the itty bitty word
	
	la $a0, NewLine	#Print a newline after their character
	li $v0, 4		#Make Syscall ready for a string
	syscall			#print whatever is in a0
	
	la $a0, CharBuffer
	lb $a0, ($a0)		#Get the value of the itty bitty word
	#Fall Through
checkguess:	#This will check if the letter they entered is contained in the string to guess
			#$a0 is Byte of their guess
	li $t0, 0		#Intializes the address incrimenter
	li $t1, 0		#Intializes the counter of occurences
	#Fall Through
checkletter:	#This is the primary loop header used by checkguess to count occurences of a letter
	lb $t2, WordToGuess($t0)	#Load the specific character into address counter
	beqz $t2, endcheckguess		#If the letter we are at is the end, return to tell them of their deeds
	bne $t2, $a0, differentchar	#The letter is the different, skip till differentchar
	sb $a0, HiddenWord($t0)		#Saves the letter they guessed into the memory location of HiddenWord + $t0
	addi $t1, $t1, 1			#Incriment the count of how many correct matches there were
	#Fall Through
differentchar:
	addi $t0 , $t0, 1	#Move to the next character in the string
	j checkletter
endcheckguess:
	add $v0, $t1, $zero
	j return
##########END readletter
###############START readwordtoguess
readwordtoguess: 		#This will get a new WordToGuess unless they deny in which case it will reuse what is already in there
	la $a0, EnterWord	#Load the enter word prompt
	li $v0, 4			#Make Syscall ready for a string
	syscall				#print whatever is in a0
	
	la $a0, WordBuffer	#Load the address of the buffer into $a0
	li $a1, 29			#Give the string a max size of 29 characters cause any more is 2eztbh
	li $v0, 8			#Get Syscall ready to eat a string
	syscall				#Read in their input
	
	la $a1, No						#Get the address of No
	lb $a1, ($a1)					#Get the value of No
	lb $a0, ($a0)					#Get the value of the first char of users input
	bne $a0, $a1, continuereadword	#If it isn't an n, continue to reset word n'stuff
	
	la $a0, WordBuffer					#Load the address of the buffer into $a0 cayse we broke that
	addi $a0, $a0, 2					#Go to the next character, skipping the return character
	lb $a0, ($a0)						#Get the second or third character depending if you are a python and care about space WAY too much
	beq $a0, $zero, generatehiddenword	#If they entered n followed by LITERALLY NOTHING, go generate the hidden word
continuereadword:
	li $t0, 0	#Set up a swirly circle thing that connects to itself, HOOLA
moveenterwordloop:
	lb $t1, WordBuffer($t0)				#Load the byte from the word they entered
	sb $t1, WordToGuess($t0)			#Place the byte into the WordToGuess
	addi $t0, $t0, 1					#Incriment counter
	bne $t1, $zero, moveenterwordloop	#If it is not the end of the string, continue the loop
generatehiddenword:
	li $t0, 0	#Set up the loopty loop
	#Fall Through
generatehiddenwordloop:
	li $t1, 95					#So basically this junk makes it have the value an underscore in $t1, MAGIC NUMBER HOOOOOOO
	sb $t1, HiddenWord($t0)		#And this junk saves the underscore to the next space in the Hidden word
	addi $t0, $t0, 1			#incriment counter if you still happen to be here
	lb $t2, WordToGuess($t0)
	beqz $t2 endgeneratehiddenword
	j generatehiddenwordloop
endgeneratehiddenword:
	addi $t0, $t0, -1
	li $t1, 0
	sb $t1, HiddenWord($t0)
###############END readwordtoguess
checkwin:
	li $t0, 0		#Once again, we will become dizzy
checkwinloop:
	lb $t1, HiddenWord($t0)	#Load
	beqz $t1, gamewin
	beq $t1, 95, return
	addi $t0, $t0, 1
	j checkwinloop
gamelose:
	la $a0, ShowWord
	jal printstr
	la $a0, WordToGuess
	jal printstr
	jal printhiddenword	#Show them whatever progress they have made, Because it will never be enough to impress me
	la $a0, GameOver	#Get ready to tell them how pathetic they are
	jal printstr		#Give someone a bad memory they will remember forever
	j gameend
gamewin: 
	jal printhiddenword	#Show them whatever progress they have made, Because it will never be enough to impress me
	la $a0, GameWin		#Get ready to tell them how pathetic they are
	jal printstr		#Give someone a bad memory they will remember forever
gameend:
	la $a0, CharBuffer	#Load the address of the buffer into $a0
	li $a1, 2			#Give the string a max size of 1 cause I asked for it
	li $v0, 8			#Get Syscall ready to CONSUME a string
	syscall				#Read in their input
	la $a1, No			#Get the address of No
	lb $a1, ($a1)		#Get the value of No
	lb $a0, ($a0)		#Get the value of the first char of users input
	bne $a0, $a1, main	#If it isn't an n, let them try their miserable hand at the game again
	j exit
###############START printhiddenword
printhiddenword:
	la $a0, CharBuffer	#Address
	li $t0, 0			#Counter
	li $v0, 4			#Action			A/C/A?
printhiddenwordloop:
	lb $t1, HiddenWord($t0)		#First, get the letter
	beqz $t1, endprinthidden	#If it is 0, we are at the end of the hidden word
	sb $t1, CharBuffer			#Load the Char into the address to print
	syscall						#PRINTIT
	
	li $t1, 32			#Load a space
	sb $t1, CharBuffer	#Into that space
	syscall				#And Space out
	addi $t0, $t0, 1	#Then add one, for reasons of looping purposes
	
	j printhiddenwordloop	#DO IT AGAIN, YEAH YEAH YEAH
endprinthidden:
	la $a0, NewLine
	syscall
	j return
###############END printhiddenword
draw:	#Draw the hanging man
	#Arg $t0, how many lives are left
	li $v0, 4
	bne $t0, 0, trydraw1
	la $a0, Draw0
	j enddraw
trydraw1:
	bne $t0, 1, trydraw2
	la $a0, Draw1
	j enddraw
trydraw2:
	bne $t0, 2, trydraw3
	la $a0, Draw2
	j enddraw
trydraw3:
	bne $t0, 3, trydraw4
	la $a0, Draw3
	j enddraw
trydraw4:
	bne $t0, 4, trydraw5
	la $a0, Draw4
	j enddraw
trydraw5:
	bne $t0, 5, trydraw6
	la $a0, Draw5
	j enddraw
trydraw6:
	la $a0, Draw6
	j enddraw
enddraw:
	syscall
	j return
return:
	jr $ra		#Return
