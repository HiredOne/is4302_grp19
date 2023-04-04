// adapted from Zac Mitton, License: MIT

pragma solidity ^0.5.0;

library PriorityQueue{ // max-heap

  uint constant ROOT_INDEX = 1;

  struct Data{
    uint256 idCount;
    Node[] nodes; // root is index 1; index 0 not used
    mapping (uint256 => uint) indices; // unique id => node index
  }

  // Each node will be a Request
  struct Node {
    uint256 id; //use with another mapping to store arbitrary object types
    uint256 priority;
  }

  // Call init before anything else
  function init(Data storage self) internal{
    if(self.nodes.length == 0) self.nodes.push(Node(0,0));
  }

  function insert(Data storage self, uint256 priority) internal returns (Node memory){//√
    if(self.nodes.length == 0){ init(self); }// test on-the-fly-init
    self.idCount++;
    self.nodes.length++;
    Node memory n = Node(self.idCount, priority);
    _bubbleUp(self, n, self.nodes.length-1);
    return n;
  }
  function extractMax(Data storage self) internal returns(Node memory){//√
    return _extract(self, ROOT_INDEX);
  }
  function extractById(Data storage self, uint256 id) internal returns(Node memory){//√
    return _extract(self, self.indices[id]);
  }

  // view
  function dump(Data storage self) internal view returns(Node[] memory){
  //note: Empty set will return `[Node(0,0)]`. uninitialized will return `[]`.
    return self.nodes;
  }
  function getById(Data storage self, uint256 id) internal view returns(Node memory){
    return getByIndex(self, self.indices[id]); //test that all these return the emptyNode
  }
  function getByIndex(Data storage self, uint i) internal view returns(Node memory){
    return self.nodes.length > i ? self.nodes[i] : Node(0,0);
  }
  function getMax(Data storage self) internal view returns(Node memory){
    return getByIndex(self, ROOT_INDEX);
  }
  function size(Data storage self) internal view returns(uint){
    return self.nodes.length > 0 ? self.nodes.length-1 : 0;
  }
  function isNode(Node memory n) internal pure returns(bool){ return n.id > 0; }

  // Private
  function _extract(Data storage self, uint i) private returns(Node memory){//√
    if(self.nodes.length <= i || i <= 0){ return Node(0,0); }

    Node memory extractedNode = self.nodes[i];
    delete self.indices[extractedNode.id];

    Node memory tailNode = self.nodes[self.nodes.length-1];
    self.nodes.length--;

    if(i < self.nodes.length){ // if extracted node was not tail
      _bubbleUp(self, tailNode, i);
      _bubbleDown(self, self.nodes[i], i); // then try bubbling down
    }
    return extractedNode;
  }
  function _bubbleUp(Data storage self, Node memory n, uint i) private{//√
    if(i==ROOT_INDEX || n.priority <= self.nodes[i/2].priority){
      _insert(self, n, i);
    }else{
      _insert(self, self.nodes[i/2], i);
      _bubbleUp(self, n, i/2);
    }
  }
  function _bubbleDown(Data storage self, Node memory n, uint i) private{//
    uint length = self.nodes.length;
    uint cIndex = i*2; // left child index

    if(length <= cIndex){
      _insert(self, n, i);
    }else{
      Node memory largestChild = self.nodes[cIndex];

      if(length > cIndex+1 && self.nodes[cIndex+1].priority > largestChild.priority ){
        largestChild = self.nodes[++cIndex];// TEST ++ gets executed first here
      }

      if(largestChild.priority <= n.priority){ //TEST: priority 0 is valid! negative ints work
        _insert(self, n, i);
      }else{
        _insert(self, largestChild, i);
        _bubbleDown(self, n, cIndex);
      }
    }
  }

  function _insert(Data storage self, Node memory n, uint i) private{//√
    self.nodes[i] = n;
    self.indices[n.id] = i;
  }
}