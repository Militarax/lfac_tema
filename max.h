struct basicTypes
{
	union
	{
		int intval;
		float floatval;
		char* strval;
		char charval;
	};
	char type;
};

struct node
{
	int type;
	struct node* next;
};

struct functionEntry
{
	char name[100];
	char scope[100];
	struct node* signature;
	int type;
	struct functionEntry* next;
};

struct basicEntry
{
	char name[100];
	char scope[100];
	int boolvalue;
	char charvalue;
	int intvalue;
	float floatvalue;
	char* strvalue;
	char isConstant;
	char isDefined;
	int type;
	int dimension;
	struct basicEntry* next;
};