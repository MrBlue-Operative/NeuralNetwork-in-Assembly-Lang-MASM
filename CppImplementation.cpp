#include <iostream>
#include <vector>
#include <cmath>
using namespace std;
// We have four slots in a place _ _ _ _ , in each  slot, there could be a male standing or a female standing,
// no slot can be empty, meaning there has to be a male or a female in a slot, our goal is to observe that if there are
// two male standing side by side or not. if yes then we have to give output of 1 else 0. I have built the neural network
// to solve this silly and simple problem
int main() {
	vector<vector<int>> inputs = {
		{0,0,0,0},{0,0,0,1},{0,0,1,0},{0,0,1,1},
		{0,1,0,0},{0,1,0,1},{0,1,1,0},{0,1,1,1},
		{1,0,0,0},{1,0,0,1},{1,0,1,0},{1,0,1,1},
		{1,1,0,0},{1,1,0,1},{1,1,1,0},{1,1,1,1}
	};
	vector<int> outputs = {0,0,0,1,0,0,1,1,0,0,0,1,1,1,1,1};

	vector<double> weights = {0.1, 0.4, 0.5, 0.1};
	int epochs = 1000000;
	double learning_rate = 0.01;

	while (epochs--) {
		double total_loss = 0;
		for (int i = 0; i < 16; i++) {
			double y = (inputs[i][0]*weights[0] +
			            inputs[i][1]*weights[1] +
			            inputs[i][2]*weights[2] +
			            inputs[i][3]*weights[3]);

			double error = outputs[i] - y;
			total_loss += error * error;

			for (int j = 0; j < 4; j++) {
				weights[j] += learning_rate * error * inputs[i][j];
			}
		}
		if (epochs % 100 == 0)
			cout << "Loss: " << total_loss << endl;
	}

	// Testing
    double accuracy = 0;
    for (int i = 0; i < 16; i++) {
        double y = (inputs[i][0]*weights[0] +
                    inputs[i][1]*weights[1] +
                    inputs[i][2]*weights[2] +
                    inputs[i][3]*weights[3]);

        cout << inputs[i][0] << " " << inputs[i][1] << " "
             << inputs[i][2] << " " << inputs[i][3]
             << " | Pred: " << (y > 0.5 ? 1 : 0)
             << " | Actual: " << outputs[i]
			 << " (" << y << ")" << endl;
		 accuracy += ((y > 0.5 ? 1 : 0) == outputs[i]);

    }
    cout << "Accuracy: " << (accuracy/16) * 100 << endl;
	return 0;
}