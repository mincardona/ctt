class IHaveMemory {
public:
   /**
    * Default constructor
    * This can be made private if necessary.
    */
    IHaveMemory() {
        
    }
    
   /**
    * Copy constructor
    */
    IHaveMemory(const IHaveMemory& other) {
        
    }
    
   /**
    * Move constructor
    */
    IHaveMemory(const IHaveMemory& other)
    : IHaveMemory() // initialize via default constructor
    {
        swap(*this, other);
    }
    
   /**
    * Destructor
    */
    virtual ~IHaveMemory() {
        
    }
    
   /**
    * Copy assignment operator
    */
    virtual IHaveMemory& operator=(IHaveMemory other) {
        swap(*this, other);
        return *this;
    }
    
   /**
    * Member swap
    */
    friend virtual void swap(IHaveMemory& lhs, IHaveMemory& rhs) {
        // enable ADL
        using std::swap;
        
        // member-by-member swap
        
    }
    
private:
    
}
