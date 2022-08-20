#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/stat.h>
int main(){
    char command[64] = "ar r "; char*iter0=command+5; char*iter1=command+4;
    struct stat libstatus; struct stat ostatus;
    char ch;
    int status=0; int write=0;

    FILE * fd = fopen("libs.txt", "r");
    while((ch=fgetc(fd))>=0){
        if(ch==' ' || ch=='\n'){
            *(iter1+1)='\0';
            if(*iter1=='a'){
                status = stat(iter0, &libstatus);
                if(status != 0){
                    write=1;
                }
            }
            else {
                status = stat(iter0, &ostatus);
                if(status != 0){
                    printf("ERROR: file %s missing\n", iter0);
                    return 1;
                }
                if(difftime(libstatus.st_mtime, ostatus.st_mtime) < 0){
                    write=1;
                }
            }
            iter0=iter1+2;
        }

        if(ch=='\n'){
            *(iter1+1)=0;
            if(write){
                printf("%s\n", command);
                status=system(command);
                if(status!=0){
                    return 1;
                }
            }
            iter0=command+5;
            iter1=command+4;
            write=0;
            continue;
        }
        
        *(++iter1)=ch;
    }

    fclose(fd);
}