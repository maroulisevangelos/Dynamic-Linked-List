	#Maroulis Evangelos AM:3200101	
		
		.text
		.globl main
main:	
		li $t1,-1		#$t1 = -1 (if $t1==-1, linked list is empty)
loop:					#loop for printing the menu

		la $a0,men		#give menu as parameter
		jal rd_pr		#call rd_pr
				
		beq $v0,0,exit	#if answer is 0, exit
		bgt $v0,3,answer_out	#if answer>3, print error message 
		bge $v0,1,in	#if answer<=3 && answer>=1,do what the user want,else print error message
answer_out:

		la $a0,out		#give out as parameter
		jal prnt		#call prnt
		j loop			#go to the beginning of the loop
in:	
		
		beq $v0,1,i		#if answer==1, call insert
		beq $t1,-1,is_empty #if linked list is empty and user want to delete or print, print eeror message
		beq $v0,2,d		#if answer==2, call delete
		beq $v0,3,p		#if answer==3, call print
is_empty:
		la $a0,empty	#give empty as parameter
		jal prnt		#call prnt
		j loop			#go to the beginning of the loop
		
i:	
		jal insert		#call insert
		j loop			#go to the beginning of the loop
		

d:	
		jal delete		#call delete
		j loop			#go to the beginning of the loop
		

p:
		jal print		#call print
		j loop			#go to the beginning of the loop
exit:	
		la $a0,exod		#give exit as parameter
		jal prnt		#call prnt
		
		li $v0,10		#go back to the operating system
		syscall





	#Name: insert, returns only $v0, which has the same price as it had when insert was called
	#insert reads an integer (using rd_pr) which user want to insert in the linked_list, 
	#and searches for the suitable place (using find) to insert the integer
	#it can create a new linked_list, add a node in the beginning, middle or end of the list
	#it uses and changes the value of $t1
insert:
		add $sp,$sp,-12		#callee saved registers:
		sw $ra,0($sp)		#saved $ra
		sw $s0,4($sp)		#$s1,
		sw $s1,8($sp)		#$s2,
		
		la $a0,inse		#give inse as parameter
		jal rd_pr		#call rd_pr
		
		move $s0,$v0	#$s6 = answer that rd_pr read and returned back
		
		li $a0,8		#2 * sizeof(int)
		li $v0,9		#sbrk - system call 9
		syscall
		
		move $s1,$v0	#$s3 = address of integer in memory
		
		sw $s0,($s1)	#store int in the first half
		
		bne $t1,-1,has_node #if $t1 != -1, go to has_node (linked_list isn't empty)
		move $t1,$s1		#$t1 = $s3
		sw $zero,4($t1)		#store zero in the second half
		
		j exit_insert	#go to exit_insert
has_node:
		move $a0,$s0	#give $s6 as parameter
		jal find		#call find
		beq $t0,0,first	#if $t0 == 0, go to first (add a node in the beginning of the linked_list)
		sw $s1,4($v0)	#store address of the new node in the second half of previous node
		beq $t0,1,not_first	#if $t0 == 1,go to not_first (add a node in the middle of the linked-list	)
		beq $t0,2,insert_at_end	#if $t0 == 2, go to insert_at_end (add a node in the end of the linked_list)
first:
		sw $t1,4($s1)	#store the current first' node address in the second half
		move $t1,$s1	#make this node first
		j exit_insert	#go to exit_insert
not_first:	
		sw $v1,4($s1)	#store address of the next node in the second half of the new node
		j exit_insert	#go to exit_insert		
insert_at_end:	
		sw $zero,4($s1)	#store zero in the second half    
	
exit_insert:
		lw $ra,0($sp)	#loaded $ra
		lw $s0,4($sp)	#$s1,
		lw $s1,8($sp)	#$s2,
		add $sp,$sp,12	#callee loaded registers
		
		li $v0,1		#$v0 = 1 (as it was in the beginning)
		jr $ra			#return
	


	#Name: delete, returns only $v0, which has the same price as it had when delete was called
	#delete reads the integer (using rd_pr) which user want to delete and then searches it in the linked-list (using find)
	#if there isn't this integer, it prints a message and goes back to main
	#if there is this integer,it changes previous node's second half, so as to show as next, node's we want to delete next
	#also, in special occasions it changes linked-list's first node, or makes the list empty (using and changing the value of $t1)
delete:
		add $sp,$sp,-20	#callee saved registers:
		sw $ra,0($sp)	#saved $ra
		sw $s0,4($sp)	#$s0,
		sw $s1,8($sp)	#$s1
		sw $s2,12($sp)	#$s2,
		sw $s3,16($sp)	#$s3
		
		la $a0,del		#give del as parameter
		jal rd_pr		#call rd_pr
		
		move $s2,$v0	#store the answer that rd_pr read and returned
		
		move $a0,$s2	#give $s2 as parameter
		jal find		#call find
		
		move $s3,$v0	#$s3 = previous node
		
		beq $t0,2,not_exist #if $t0 == 2, go to not_exist
		
		lw $s0,($v1)	#$s0 = first half of $v1
		bne $s0,$a0,not_exist #if $s0 != $a0, go to not_exist
		
		la $a0,dl		#give dl as parameter
		jal prnt		#call prnt
		
		move $a0,$s2
		li $v0,1		#print the integer you deleted
		syscall
		
		la $a0,CTRL		#give CTRL as parameter 
		jal prnt		#call prnt
		
		beq $t0,1,not_the_first	#if $t0 == 1, you don't delete the first node
		beq $t0,0,the_first #if $t0 == 0, you delete the first node
not_exist:
		la $a0,nexist	#give nexist as parameter
		jal prnt		#call prnt
		j exit_delete	#go to exit_delete
the_first:
		lw $s1,4($v1)	#$s1 = the second node of the list
		move $t1,$s1	#$t1 = $s1 (now, first node of the list is the second node
		beqz $s1,make_it_empty #if first node's next address == 0 , the list is now empty (because the list had only one node and now you deleted it)
		j exit_delete	#go to exit_delete
make_it_empty:
		li $t1,-1		#make the list empty
		j exit_delete	#go to exit_delete
not_the_first:
		lw $s1,4($v1)	#$s1 = next node
		sw $s1,4($s3)	#make previous node's next, the next of this one you deleted 
exit_delete:
		lw $ra,0($sp)	#loaded $ra
		lw $s0,4($sp)	#$s0,
		lw $s1,8($sp)	#$s1,
		lw $s2,12($sp)	#$s2,
		lw $s3,16($sp)	#$s3
		add $sp,$sp,20	#callee loaded registers
		li $v0,2		#$v0 = 2 (as it was in the beginning)
		jr $ra			#return






	#Name: print, returns only $v0, which has the same price as it had when print was called
	#print runs the whole linked list using $t1(first node of the list),
	#and prints the value of every node with a ", " in the middle
print:
		add $sp,$sp,-12		#callee saved registers:
		sw $ra,0($sp)		#saved $ra
		sw $s0,4($sp)		#$s0,
		sw $s1,8($sp)		#$s1
		
		la $a0,pr			#give pr as parameter
		jal prnt			#call prnt
				
		move $s0,$t1		#$s0 = $t1
		li $s1,0			#$s1 = 0
loop_print:
		beq $s0,0,exit_loop		#if $s0 == 0, exit from the loop
		beq $s1,0,first_loop	#if $s1 == 0, don't print comma
		la $a0,comma			#give comma as parameter
		jal prnt				#call prnt
first_loop:
		lw $a0,($s0)
		li $v0,1			#print the value of the node
		syscall

		li $s1,1			#$s1 = 1
		
		lw $s0,4($s0)		#$s0 = next Node
		j loop_print		#go back to loop_print
	
exit_loop:
		la $a0,CTRL			#give CTRL as parameter
		jal prnt			#call prnt
		
		lw $ra,0($sp)		#loaded $ra
		lw $s0,4($sp)		#$s0,
		lw $s1,8($sp)		#$s1
		add $sp,$sp,12		#callee loaded registers:
		
		li $v0,3			#$v0 = 3 (as it was in the beginning)
		jr $ra				#return




	#Name:rd_pr, takes as parameter $a0 which contains a message to print, 
	#returns $v0 which is an integer as answer to the previous message
	#rd_pr prints the message, reads the answer from the user and return it
rd_pr:

		li $v0,4	#print the message you took as parameter
		syscall
		
		li $v0,5	#read the answer from the user
		syscall
		
		jr $ra		#return
	

	
	#Name:prnt, takes as parameter $a0 which contains a message to print
	#prnt prints the message
prnt:
	
		li $v0,4	#print the message you took as parameter
		syscall
		
		jr $ra		#return


	#Name:find , takes as parameter $a0 which contains an integer,
	#if there is $a0 in the linked-list:
	#it returns the previous($v0) and the node which contains $a0 ($v1)
	#if there is not $a0 in the linked_list:
	#it returns the previous($v0) and the next($v1) node
	#if there is not $a0 in the linked_list and all integers are lower than $a0:
	#it returns the last node ($v0)
	#find runs the whole linked_list until it finds an integer higher than $a0,
	#or until it arrives at the end of the list
	#it also uses and changes the value of $t0
find:
		add $sp,$sp,-16		#callee saved registers:
		sw $s1,0($sp)		#$s1,
		sw $s2,4($sp)		#$s2,
		sw $s3,8($sp)		#$s3,
		sw $s4,12($sp)		#$s3,
		
		
		move $s1,$t1	#$s1 = $t1 
		lw $s4,($s1)	#$s4 = first node's integer
		lw $s2,4($s1)	#$s2 = first node's next
		move $s3,$t1	#$s3 = $t1 
		li $t0,0		#$t0 = 0
loop_findp:
		ble $a0,$s4,findp	#if $a0  <= $s4, go to findp 
		li $t0,1			#$t0 = 1
		move $s3,$s1		#$s3 = the node you checked before
		beq $s2,0,until_end	#if the address of next node == 0, go to until_end
		lw $s1,4($s1)		#$s1 = the next node
		lw $s4,($s1)		#$s4 = $s1's integer
		lw $s2,4($s1)		#$s2 = $s1's next address
		j loop_findp		#go to loop_findp
#if you are looking for a specifice integer, it would be in the node $s1
#if you are looking for a place to insert an integer, you have to do it before node $s1 and after $s3
findp:
		move $v1,$s1		#$v1 = $s1 (value to return)
		j exit_find			#go to exit_find
#there isn't an integer higher than this you are looking for
until_end:
		li $t0,2			#$t0 = 2
exit_find:
		move $v0,$s3		#$v0 = $s3 (value to return)
		lw $s1,0($sp)		#$s1,
		lw $s2,4($sp)		#$s2,
		lw $s3,8($sp)		#$s3,
		lw $s4,12($sp)		#$s4,
		add $sp,$sp,16		#callee loaded registers:
		jr $ra				#return
		
		.data
men:	.asciiz	"1.Instert\n2.Delete\n3.Print\n0.Exit\nChoose a number: "
out:	.asciiz "This is not in the menu!\n"
inse:	.asciiz "Give an integer to insert: "
del: 	.asciiz "Give an integer from the list to delete: "
pr:		.asciiz "I print the whole list:\n"
exod:	.asciiz "Exit"
comma:	.asciiz ", "
CTRL:	.asciiz "\n"
empty:	.asciiz "List is empty\n"
nexist:	.asciiz "This integer doesn't exist!\n"
dl:		.asciiz "I deleted integer: "