Describe "Menu status"{
    it "test: different status types cannot share the same line"{
        {
            New-Menu "Pester"{
                
            }
        }|should -not -Throw

    }
    it "test: filter needs to exist in the same menu if defined"{
        
    }
}