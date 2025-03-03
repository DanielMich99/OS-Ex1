#!/bin/bash

#
#variables

gameOn=true
declare -i p1Choice=0
declare -i p2Choice=0
declare -i p1Points=50
declare -i p2Points=50
declare -i ballPosition=0


#print points left
pointsLeft() {
    echo -e " Player 1: ${1}         Player 2: ${2} "
}


#print last play
pointsPlayed() {
    echo -e "       Player 1 played: ${1}\n       Player 2 played: ${2}\n\n"
}


drawBall() {
    case $1 in 

    -3)
        echo "0|       |       #       |       | "
        ;;

    -2)
        echo " |   O   |       #       |       | "
        ;;

    -1)
        echo " |       |   O   #       |       | "
        ;;

    0)
        echo " |       |       O       |       | "
        ;;

    1)
        echo " |       |       #   O   |       | "
        ;;

    2)
        echo " |       |       #       |   O   | "
        ;;

    3)
        echo " |       |       #       |       |O"
    esac
}

# create board
createBoard() {
    pointsLeft $1 $2
    echo "---------------------------------"
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    drawBall $3
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    echo "---------------------------------"
    case $4 in
    false)
        #do nothing
        ;;
    true)
        pointsPlayed $5 $6
        ;;
    esac

}

#get points from user
getPoints() {
    re='^[0-9]+$' 
    waiting_for_number=true

    # while waiting for a valid is true
    while [ "$waiting_for_number" = true ]; do
        echo "PLAYER ${1} PICK A NUMBER: "
        read -s num
        if [[ $num =~ $re ]] && [ $num -le $2 ] ; then
            case $1 in 
            1)          
                p1_serve=$num
                ;;
            2)
                p2_serve=$num
                ;;
            esac
            waiting_for_number=false
        else
            echo "NOT A VALID MOVE !"
        fi
    done
}

#move the ball acording to the points
moveBall() {
    #if player 1 won the move
    if [ $1 -gt $2 ]; then
        if [ $ballPosition -lt 0 ]; then
            #set ball position to 1
            ballPosition=1
        else 
            #increment ball position
            ballPosition=$((ballPosition + 1))
        fi
    fi

    #if player 2 won the move
    if [ $1 -lt $2 ]; then
        if [ $ballPosition -gt 0 ]; then
            #set ball position to -1
            ballPosition=-1
        else 
            #decrement ball position
            ballPosition=$((ballPosition - 1))
        fi
    fi
}

#update points
updatePoints() {
    p1Points=$((p1Points - p1_serve))
    p2Points=$((p2Points - p2_serve))
}

#check if game is over
gameOverCheck() {
    #if the ball is at the end of the right side of the board player 1 wins the game,
    #else if the ball is at the end of the left side of the board player 2 wins the game.
    if [ $ballPosition -eq 3 ]; then
        echo "PLAYER 1 WINS !"
        gameOn=false
        return
    elif [ $ballPosition -eq -3 ]; then
        echo "PLAYER 2 WINS !"
        gameOn=false
        return
    fi

    #if player 1 has points and player 2 doesn't have points player 1 wins the game, else if player 2 has points and player 1 doesn't have points player 2 wins the game.
    if [ $p1Points -gt 0 ] && [ $p2Points -eq 0 ]; then
        echo "PLAYER 1 WINS !"
        gameOn=false
        return
    elif [ $p2Points -gt 0 ] && [ $p1Points -eq 0 ]; then
        echo "PLAYER 2 WINS !"
        gameOn=false
        return
    fi

    #if both players have 0 points and the ball position is on the right side of the board player 1 wins the game,
    #if both players have 0 points and the ball position is on the left side of the board player 2 wins the game,
    #else if both players have 0 points and the ball position is in the middle of the board the game is a draw.
    if [ $p1Points -eq 0 ] && [ $p2Points -eq 0 ] && [ $ballPosition -gt 0 ]; then
        echo "PLAYER 1 WINS !"
        gameOn=false
    elif [ $p1Points -eq 0 ] && [ $p2Points -eq 0 ] && [ $ballPosition -lt 0 ]; then
        echo "PLAYER 2 WINS !"
        gameOn=false
    elif [ $p1Points -eq 0 ] && [ $p2Points -eq 0 ] && [ $ballPosition -eq 0 ]; then
        echo "IT'S A DRAW !"
        gameOn=false
    fi 
}

#main loop
createBoard $p1Points $p2Points $ballPosition false
while [ "$gameOn" = true ]; do
    #clear
    #createBoard $p1Points $p2Points $ballPosition false
    getPoints 1 $p1Points
    getPoints 2 $p2Points
    moveBall $p1_serve $p2_serve
    updatePoints
    createBoard $p1Points $p2Points $ballPosition true $p1_serve $p2_serve
    gameOverCheck
done
