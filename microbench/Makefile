CXX = g++
CXXFLAGS += -g -O3 -std=c++0x
LDFLAGS =

TBENCH_PATH = ../harness
TBENCH_SERVER_OBJ = $(TBENCH_PATH)/tbench_server_networked.o
TBENCH_CLIENT_OBJ = $(TBENCH_PATH)/client.o $(TBENCH_PATH)/tbench_client_networked.o
TBENCH_INTEGRATED_OBJ = $(TBENCH_PATH)/client.o $(TBENCH_PATH)/tbench_server_integrated.o

CXXFLAGS += -I$(TBENCH_PATH)
LDFLAGS += -lrt -pthread

BINS = microbench_integrated microbench_server_networked microbench_client_networked

.PHONY : all
all : $(BINS)

microbench.o : microbench.cpp
	$(CXX) $(CXXFLAGS) $< -c -o $@

client.o : client.cpp
	$(CXX) $(CXXFLAGS) $< -c -o $@

# train : train.o common.o
# 	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

microbench_integrated : microbench.o client.o $(TBENCH_INTEGRATED_OBJ)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

microbench_server_networked : microbench.o $(TBENCH_SERVER_OBJ)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

microbench_client_networked : client.o $(TBENCH_CLIENT_OBJ)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

.PHONY : clean
clean:
	rm *.o $(BINS)
