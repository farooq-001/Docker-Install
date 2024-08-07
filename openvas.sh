# openvas
 sudo apt install docker.io
 sudo docker pull mikesplain/openvas
 sudo docker run -d -p 443:443 --name openvas mikesplain/openvas
 # Function to display dragon ASCII art
function draw_dragon {
    echo "                           / \\  //\\"
    echo "               |\\___/|   /   \\//  \\\\"
    echo "               /0  0  \\__  /    //  | \\ \\"
    echo "              /     /  \\/_/    //   |  \\  \\"
    echo "              \@_^_\\'/   \\/_   //    |   \\   \\"
    echo "              //_^_/     \\/_ //     |    \\    \\"
    echo "           ( //) |        \\\///      |     \\     \\"
    echo "         ( / /) _|_ /   )  //       |      \\     _\\"
    echo "       ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-."
    echo "     (( / / )) ,-{        _      \`-.|.-~-.           .~         \`."
    echo "    (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \\"
    echo "    (( /// ))      \`.   {            }                   /      \\  \\"
    echo "     (( / ))     .----~-.\\        \\-'                 .~         \\  \`."
    echo "                ///.----..>        \\             _ -~            \`\\\"\`."
    echo "                  ///-._ _ _ _ _ _ _}^ - - - - ~                     \`"
}

# Main script execution
echo "openvas installation complete:"
draw_dragon

 echo "installation complete"
 sleep 1
 sudo docker ps -a --filter name=openvas
 sleep 2
 echo "user-name: admin"
 echo "password: admin" 
