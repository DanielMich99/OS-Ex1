#!/bin/bash
#Daniel Michaelshvili 207795030

#
#variables
p1_win="PLAYER 1 WINS !"
p2_win="PLAYER 2 WINS !"
play=true
declare -i p1Points=50
declare -i p2Points=50
declare -i p1Choice=0
declare -i p2Choice=0
declare -i ballPosition=0


#print points left
points_left() {
    echo -e " Player 1: ${1}         Player 2: ${2} "
}


#print last play
points_played() {
    echo -e "       Player 1 played: ${1}\n       Player 2 played: ${2}\n\n"
}


draw_ball() {
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
    points_left $1 $2
    echo "----------------------------------"
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    draw_ball $3
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    echo "----------------------------------"
    case $4 in
    false)
        #do nothing
        ;;
    true)
        points_played $5 $6
        ;;
    esac

}

#get points from user
get_points() {
    re='^[0-9]+$' 
    waiting_for_number=true
    invalid="NOT A VALID MOVE !"
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
            echo $invalid
        fi
    done
}

#move the ball acording to the points
move_ball() {
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
update_points() {
    p1Points=$((p1Points - p1_serve))
    p2Points=$((p2Points - p2_serve))
}

#check if game is over
gameOverCheck() {
    #if the ball is at the end of the right side of the board player 1 wins the game,
    #else if the ball is at the end of the left side of the board player 2 wins the game.
    if [ $ballPosition -eq 3 ]; then
        echo $p1_win
        play=false
    elif [ $ballPosition -eq -3 ]; then
        echo $p2_win
        play=false
    fi

    #if player 1 has points and player 2 doesn't have points player 1 wins the game, else if player 2 has points and player 1 doesn't have points player 2 wins the game.
    if [ $p1Points -gt 0 ] && [ $p2Points -eq 0 ]; then
        echo $p1_win
        play=false
    elif [ $p2Points -gt 0 ] && [ $p1Points -eq 0 ]; then
        echo $p2_win
        play=false
    fi

    #if both players have 0 points and the ball position is on the right side of the board player 1 wins the game,
    #if both players have 0 points and the ball position is on the left side of the board player 2 wins the game,
    #else if both players have 0 points and the ball position is in the middle of the board the game is a draw.
    if [ $p1Points -eq 0 ] && [ $p2Points -eq 0 ] && [ $ballPosition -gt 0 ]; then
        echo $p1_win
        play=false
    elif [ $p1Points -eq 0 ] && [ $p2Points -eq 0 ] && [ $ballPosition -lt 0 ]; then
        echo $p2_win
        play=false
    elif [ $p1Points -eq 0 ] && [ $p2Points -eq 0 ] && [ $ballPosition -eq 0 ]; then
        echo "IT'S A DRAW !"
        play=false
    fi 
}

#main loop
createBoard $p1Points $p2Points $ballPosition false
while [ "$play" = true ]; do
    #clear
    #createBoard $p1Points $p2Points $ballPosition false
    get_points 1 $p1Points
    get_points 2 $p2Points
    move_ball $p1_serve $p2_serve
    update_points
    createBoard $p1Points $p2Points $ballPosition true $p1_serve $p2_serve
    gameOverCheck
done
