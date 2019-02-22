# Algorithm Discover Neighbors

Algorithm to discover neighbors implemented in nesC to plataform TinyOs.
To compile the application for the TOSSIM simulator, run the following command in the terminal:

 *make micaz sim

Then, to perform the simulation of the application on a predefined network in the simulador folder, run the command:

*python test.py

To view the output of the algorithm, check the log.txt file created after execution.

This algorithm performs the discovery of neighbors through broadcaste messages in the network triggered from the reception of the sensor message with id 0.

implemented by Alexandre Ordakowski
alexandre.ordako@gmail.com
