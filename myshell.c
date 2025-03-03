
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMAND_LENGTH 100
#define MAX_HISTORY_COMMANDS 100
#define MAX_DIGITS_PID 19
#define SIZE_OF_SPACE 1
#define ERROR_MESSAGE_LENGTH 50

/*a function that gets a path and adds it to the PATH environment variable*/
void addPath(char *path) {
    char *currentPath = getenv("PATH");
    char *newPath = (char *) calloc((strlen(currentPath) + strlen(path) + 2), sizeof(char));
    sprintf(newPath, "%s:%s", currentPath, path);
    setenv("PATH", newPath, 1);
    free(newPath);
}

//a function that adds a command to the history array
void addCommand(int pidNumber, char *command, char *history[], int *numOfCommands) {
    //if the number of commands is less than 100, then add the command to the history array
    if (*numOfCommands < MAX_HISTORY_COMMANDS) {
        //allocate memory for a string that will contain the command and the pid number
        char *commandWithPid = (char *) calloc((MAX_COMMAND_LENGTH + MAX_DIGITS_PID + SIZE_OF_SPACE),sizeof(char));
        //give commandWithPid a string that consists of "'pid number' 'command'"
        sprintf(commandWithPid, "%d %s", pidNumber, command);
        //add the command to the history array

        history[*numOfCommands] = commandWithPid;
        *numOfCommands = *numOfCommands + 1;
    } 
}

//a function that prints the history array of the last 100 commands
void printHistory(char *history[], int numOfCommands) {
    int i;
    //print the history array
    for (i = 0; i < numOfCommands; i++) {
        printf("%s\n", history[i]);
    }
}

//a function that frees the memory allocated for the history array
void freeHistory(char *history[], int numOfCommands) {
    int i;
    //free the memory allocated for the history array
    for (i = 0; i < numOfCommands; i++) {
        free(history[i]);
    }
}

int main(int argc, char *argv[])
{   //CREATE A HISTORY ARRAY TO STORE THE LAST 100 COMMANDS AND INITIALIZE IT TO NULL
    char *history[MAX_HISTORY_COMMANDS];
    int numOfCommands = 0;
    char command[MAX_COMMAND_LENGTH];
    char *args[MAX_COMMAND_LENGTH];
    int i = 0;
    pid_t pid;
    int status;
    
    for (int i = 1; i < argc; i++) {
        addPath(argv[i]);
    }

    while (1) {

        // empty the command array
        for (int i = 0; i < MAX_COMMAND_LENGTH; i++) {
            command[i] = '\0';
        }
        printf("$ ");
        fflush(stdout);
        fgets(command, MAX_COMMAND_LENGTH, stdin);
        command[strlen(command) - 1] = '\0';
        char commandCopy[MAX_COMMAND_LENGTH];

        //copy all the characters from command to commandCopy
        strcpy(commandCopy, command);

        args[i] = strtok(commandCopy, " ");
        while (args[i] != NULL) {
            i++;
            args[i] = strtok(NULL, " ");
        }

        //if the command is cd, then change the directory of the parent process, makes sure also that the only argument is the directory name.
        if (strcmp(args[0], "cd") == 0) {
            if (args[1] == NULL) {
                printf("cd: missing argument\n");
            } else if (chdir(args[1]) < 0) {
                perror("cd failed\n");
            }
            addCommand(getpid(), command, history, &numOfCommands);

            //empty the args array
            for (i = 0; i < MAX_COMMAND_LENGTH; i++) {
                args[i] = NULL;
            }
            
            // empty the command array
            for (i = 0; i < MAX_COMMAND_LENGTH; i++) {
                command[i] = '\0';
            }
            i = 0;
            continue;
        }

        if (strcmp(args[0], "history") == 0) {

            // Add the command and PID to history in the parent process
            addCommand(getpid(), command, history, &numOfCommands);
            printHistory(history, numOfCommands);
            continue;
        }

        if (strcmp(args[0], "exit") == 0) {
            break;
        }

        pid = fork();
        if (pid < 0) {
            char error_message[50];
            sprintf(error_message, "%s failed\n", args[0]);
            perror(error_message);
            exit(1);
        } else if (pid == 0) {
            if (execvp(args[0], args) < 0) {
                char error_message[ERROR_MESSAGE_LENGTH];
                sprintf(error_message, "%s failed\n", args[0]);
                perror(error_message);
                exit(1);
            }
        } else {

            // Add the command and PID to history in the parent process
            addCommand(pid, command, history, &numOfCommands);
            waitpid(pid, &status,0);
        }
        
        //empty the args array
        for (i = 0; i < MAX_COMMAND_LENGTH; i++) {
            args[i] = NULL;
        }

        // empty the command array
        for (i = 0; i < MAX_COMMAND_LENGTH; i++) {
            command[i] = '\0';
        }
        i = 0;
    }

    freeHistory(history, numOfCommands);

    return 0;
}