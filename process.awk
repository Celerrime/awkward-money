#!/usr/bin/awk -f
BEGIN {
	FS="\t+"
	months="Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
}

# monthdigit - returns month as an integer 1-12 (i.e., Mar = 3)
function monthdigit(mymonth) {
	return (index(months,mymonth)+3)/4
}

function doincome(mybalance) {
	mybalance[curmonth,$3] += amount
	mybalance[0,$3] += amount
}

function doexpense(mybalance) {
	mybalance[curmonth,$2] -= amount
	mybalance[0,$2] -= amount
}

function dotransfer(mybalance) {
	mybalance[0,$2] -= amount
	mybalance[curmonth,$2] -= amount
	mybalance[0,$3] += amount
	mybalance[curmonth,$3] += amount
}

{
	curmonth=monthdigit(substr($1,4,3))
	amount=$7

	# record all the categories encountered
	if ( $2 != "-" )
		globcat[$2]="yes"
	if ( $3 != "-" )
		globcat[$3]="yes"

	# tally up the transaction properly
	if ( $2 == "-" ) {
		if ( $3 == "-" ) {
			print "Error: inc and exp fields are both blank!"
			exit 1
		} else {
			#this is income
			doincome(balance)
			if ( $5 == "Y" )
				doincome(balance2)
		}
	} else if ( $3 == "-" ) {
		# this is an expense
		doexpense(balance)
		if ( $5 == "Y" )
			doexpense(balance2)
	} else {
		# this is a transfer
		dotransfer(balance)
		if ( $5 == "Y" )
			dotransfer(balance2)
	}
}

END {
	bal=0  # Unposted account balance
	bal2=0 # Posted acccount balance 
	for (x in globcat) {
		bal=bal+balance[0,x]
		bal2=bal2+balance2[0,x]

	}
	# Print Monthly Category Totals
	printf("Year Total Category Spending\n")
	printf("----------------------------\n")
	for (x in globcat) {
		print x ":", balance[0,x]
	}
	printf("\n")
	printf("Your available funds: %10.2f\n", bal)
	printf("Your account balance: %10.2f\n", bal2)
}
