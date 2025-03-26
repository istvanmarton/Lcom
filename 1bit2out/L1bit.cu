#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#define length 4096
#define NUM_OF_THREADS 16384
#define NUM_OF_BITS 8 * sizeof(unsigned long long int)

__global__ void func(int* d_mtx_to_vec, unsigned long long int steps, unsigned long long int steps_remainder, int *d_L1_vector, int *d_L1_strategy, int iLonger, int iShorter){
	int temp[length], vect[NUM_OF_BITS], product, L1, logical, i, l;
	unsigned long long int number, index, iMax, iMin, iNumofZeros, iNum_temp;
	index = blockIdx.x * blockDim.x + threadIdx.x;

	iMax = (index + 1) *(steps) - 1;
	iMin = index * (steps);
	if(index < (steps_remainder) ) iMax += index + 1;
	else iMax += (steps_remainder);
	if(index <= (steps_remainder)) iMin += index;
	else iMin += (steps_remainder);
		 number = iMin;
		 for(l=0; l < iLonger; l++) {temp[l] = d_mtx_to_vec[l];}
		 product = 0;
			for(i = 1 ; iShorter > i; i++){
				iNum_temp = (unsigned long long int) 1 << i;
				iNumofZeros=(unsigned long long int) iNum_temp >> 1;
				
				logical = ((number+ iNumofZeros)/iNum_temp) % 2;
				vect[i] = (int) 2 * logical - 1;
					if(vect[i] > 0){for(l=0; l < iLonger; l++){temp[l] += d_mtx_to_vec[i * iLonger + l]; }}
					else {for(l=0; l < iLonger; l++){temp[l] -= d_mtx_to_vec[i * iLonger + l]; }}				
			}
			for(l= 0; l < iLonger; l++) {product += abs(temp[l]);}
			L1 = product;
			for(l=1; l<iShorter; l++){d_L1_strategy[index * (iShorter - 1) + l - 1] = vect[l];}

     for(number=iMin + 1; number <= iMax; number++){
		 product = 0;
			for(i = 1 ; iShorter > i; i++){
				iNum_temp = (unsigned long long int) 1 << i;
				iNumofZeros=(unsigned long long int) iNum_temp >> 1;
				if( ((number+ iNumofZeros) % iNum_temp) == 0 ) {vect[i]=-vect[i] ;					
					if(vect[i] > 0){for(l=0; l < iLonger; l++){temp[l] += 2 * d_mtx_to_vec[i * iLonger + l]; }}
					else {for(l=0; l < iLonger; l++){temp[l] -= 2 *d_mtx_to_vec[i * iLonger + l]; }}
				break;
				}
            		}
	     for(l = 0; l < (iLonger ); l++) {product += abs(temp[l]);}
	     if(product > L1) {L1 = product;
		for(l=1; l<iShorter; l++){d_L1_strategy[index * (iShorter - 1) + l - 1] = vect[l];}
		}
     }
d_L1_vector[index] = L1;
}

int** mtx_read(int *iRows, int *iCols, char* fileName){
	int i = 0,j = 0, k = 0;
	int *row, **mtx, value;
	
	mtx = NULL;
	row = NULL;
	
	char g, cNum[256];
	
	FILE *fp;
	fp = fopen(fileName,"r");
	
	do{
		g = fgetc(fp);	
		if((((g - '0') < 10) && ((g - '0') >= 0)) || (g == 'e') || ( g == 'E') || (g == '.') || (g == '+') || (g == '-')) {cNum[i] = g; i++;}
		else {
			cNum[i] = '\0'; 
			if(cNum[0] != '\0') {sscanf(cNum, "%d", &value); j++; i = 0;  row = (int*) realloc(row, j * sizeof(int)); row[j-1] = value;}
			if( ((g == '\n') || (g == EOF)) && (j > 0)){*iCols = j; j = 0; k++; mtx = (int**) realloc(mtx, k * sizeof(int*)); mtx[k-1] = row; row = NULL;}
		}
		
	}while(!feof(fp));
	*iRows = k;
printf("rows: %d, cols: %d\n",*iRows, *iCols); 
	fclose(fp);
return mtx;
}

void fileN(char *fileName, char** argv, int *argc){
	int r;
	FILE *fp;
	if((*argc) < 2) {
		do{
			printf("Please give me a filename: "); 
			r = scanf("%s",fileName);
		}while(r != 1);
	}
	else sprintf(fileName,"%s", argv[1]);

	fp = fopen(fileName, "r");
	if(fp == NULL) {
		do{
			printf("Please give me a filename that exist within this directory: ");
			r = scanf("%s",fileName);
			fp = fopen(fileName, "r");
		}while(fp == NULL);
	}
	fclose(fp);
}

void calc_Lnorm(int* iRows, int* iCols, int* L1_max, int** mtx){
	int i, j/*, iMax*/, *mtx_to_vec, *d_mtx_to_vec, iShorter, iLonger, *L1_vector, *d_L1_vector, *L1_strategy, *d_L1_strategy, num_ofBlock, num_ofThread;
	unsigned long long int steps, steps_remainder, Inner_num , copyNum;
	cudaDeviceProp devProp;
	cudaGetDeviceProperties(&devProp, 0);
	mtx_to_vec = (int*)calloc( *iRows * *iCols, sizeof(int));
	if( *iRows > *iCols ){
		for(j = 0; j < *iCols; j++){
			for(i = 0; i < *iRows; i++){
				mtx_to_vec[j * *iRows + i] = mtx[i][j];
			}
		}
	}
	else{
		for(i = 0; i < *iRows; i++){
			for(j = 0; j < *iCols; j++){
				mtx_to_vec[i * *iCols + j] = mtx[i][j];
			}
		}
	}
	if(*iRows < *iCols) {iShorter = *iRows; iLonger = *iCols;}
	else {iShorter = *iCols; iLonger = *iRows;}
	if(iShorter > (NUM_OF_BITS)) {printf("Matrix is too big. The number of rows or columns can not be more than %lu.\n", NUM_OF_BITS); exit(-1);}
	if(iLonger > length) {printf("Matrix is too big. The length variable %d should be bigger or equal than %d.\n", length, iLonger); exit(-1);}
	cudaMalloc((void**)&d_mtx_to_vec, iShorter * iLonger * sizeof(int));
	Inner_num = (unsigned long long int) 1 << (iShorter - 1);
	copyNum = NUM_OF_THREADS > Inner_num ? Inner_num : NUM_OF_THREADS;
	num_ofThread = copyNum < devProp.warpSize ? copyNum : devProp.warpSize;
	num_ofBlock = copyNum/num_ofThread; copyNum = num_ofBlock * num_ofThread;
	if((NUM_OF_THREADS % num_ofThread) != 0) {printf("The NUM_OF_THREADS variable must be divisible with the number of threads in one block which is %d. Please modify the NUM_OF_THREADS variable and recompile this code again.\n", num_ofThread); exit(-1);}
	steps=Inner_num/copyNum; steps_remainder = Inner_num % copyNum;
	L1_vector = (int*) malloc(copyNum * sizeof(int));
	L1_strategy = (int*) malloc(copyNum * (iShorter - 1) * sizeof(int));
	cudaMalloc((void**)&d_L1_vector, copyNum * sizeof(int));
	cudaMalloc((void**)&d_L1_strategy, copyNum * (iShorter - 1) * sizeof(int));
	cudaMemcpy(d_mtx_to_vec, mtx_to_vec, iShorter * iLonger * sizeof(int), cudaMemcpyHostToDevice);
//	printf("num_ofBlock: %d, num_ofThread: %d\n",num_ofBlock,num_ofThread);
	func<<<num_ofBlock,num_ofThread>>>(d_mtx_to_vec, steps, steps_remainder, d_L1_vector, d_L1_strategy, iLonger, iShorter);
	cudaMemcpy(L1_vector, d_L1_vector, copyNum * sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(L1_strategy, d_L1_strategy, copyNum * (iShorter - 1) * sizeof(int), cudaMemcpyDeviceToHost);
	*L1_max = L1_vector[0]; //iMax = 0;
	for(i = 1; i < copyNum; i++){ if(*L1_max < L1_vector[i]) {*L1_max = L1_vector[i]; /*iMax = i;*/}}

/*	printf("L1 is: %d\n",*L1_max);

	FILE *fp;
	fp = fopen("strategy_L1.txt", "w");
	fprintf(fp,"1\n");
	for(i=0; i<(iShorter - 1); i++) {fprintf(fp, "%d\n", L1_strategy[iMax * (iShorter - 1) + i]);}
	fclose(fp);
*/
	free(L1_vector);
	free(L1_strategy);
	free(mtx_to_vec);
	cudaFree(d_L1_vector);
	cudaFree(d_L1_strategy);
	cudaFree(d_mtx_to_vec);
}

void partitionStrategy(int *iPartition, int* iRows, int* iRows0, int* iRows1, int* iCols, int* iShorter0, int* iShorter1, int* iLonger0, int* iLonger1){
	int i;
	*iRows0 = 0;
	*iRows1 = 0;
	for(i = 0; i < (*iRows); i++){
		iPartition[i] = rand() % 2;
		if(iPartition[i] == 0) {(*iRows0)++;}
		else {(*iRows1)++;}
	}

	if((*iRows0) < (*iCols)) {(*iShorter0) = (*iRows0); (*iLonger0) = (*iCols);}
	else {(*iShorter0) = (*iCols); (*iLonger0) = (*iRows0);}

	if((*iRows1) < (*iCols)) {(*iShorter1) = (*iRows1); (*iLonger1) = (*iCols);}
	else {(*iShorter1) = (*iCols); (*iLonger1) = (*iRows1);}
}

void partition_matrix(int** mtx, int** mtx0, int** mtx1, int* iPartition, int* iRows, int* iCols, int* iRows0, int* iRows1){
	int i, i0 = 0, i1 = 0, j;
	for(i = 0; i < (*iRows); i++){
		if(iPartition[i] == 0) {
				for(j = 0; j < (*iCols); j++) {
					mtx0[i0][j] = mtx[i][j];
					//printf("mtx: %d, mtov: %d\n", mtx[i][j], mtx_to_vec0[i * (*iCols) + j]);
				}
		i0++;
		}
		else {
				for(j = 0; j < (*iCols); j++) {
					mtx1[i1][j] = mtx[i][j];
					//printf("mtx: %d, mtov: %d\n", mtx[i][j], mtx_to_vec1[i * (*iCols) + j]);
				}
		i1++;
		}
	}
}

void mtx_free(int* iRows, int** mtx){
	int i;
	for(i = 0; i < *iRows; i++){
		free(mtx[i]);
	}
	free(mtx);
}

int** mtx_allocate(int* iRows, int* iCols){
	int i, **mtx;
	mtx = (int**) calloc(*iRows, sizeof(int*));
	for(i = 0; i < *iRows; i++){
		mtx[i] = (int*) calloc(*iCols, sizeof(int));
	}
return mtx;
}

int main(int argc, char *argv[]){
	char fileName[1024];
	int i, iRows, iCols, iShorter0, iShorter1, iLonger0, iLonger1, *iPartition, **mtx, **mtx0, **mtx1, iRows0, iRows1, S_max = 0, L10, L11;
	FILE *partition_strategy;
	fileN(fileName, argv, &argc);
	mtx = mtx_read(&iRows, &iCols, fileName);
	srand(time(NULL));

	iPartition = (int*) calloc(iRows, sizeof(int));
	while(1){
		partitionStrategy(iPartition, &iRows, &iRows0, &iRows1, &iCols, &iShorter0, &iShorter1, &iLonger0, &iLonger1);
		if( (iShorter0 < 41) && (iShorter1 < 41) ){
		mtx0 = mtx_allocate(&iRows0, &iCols);
		mtx1 = mtx_allocate(&iRows1, &iCols);
		partition_matrix(mtx, mtx0, mtx1, iPartition, &iRows, &iCols, &iRows0, &iRows1);
		calc_Lnorm(&iRows0, &iCols, &L10, mtx0);
		calc_Lnorm(&iRows1, &iCols, &L11, mtx1);
if((L10 + L11) > S_max ){
	S_max = L10 + L11;

	partition_strategy = fopen("Partition_strategy.txt", "a");
	fprintf(partition_strategy, "L1_0: %d, L1_1: %d, S_max: %d\n",L10, L11, S_max);
	for(i=0; i < iRows; i++){
		fprintf(partition_strategy, "%d\t", iPartition[i]);
	}
	fprintf(partition_strategy, "\n");
fclose(partition_strategy);
}
	mtx_free(&iRows1, mtx1);
	mtx_free(&iRows0, mtx0);
	}
	}
free(iPartition);
mtx_free(&iRows, mtx);
return 0;  
}
