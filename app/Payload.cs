using System;

namespace all_things
{
    public class Payload
    {
        public string message => "Automate all the things!";
        //1970, 1, 1 is the Unix epoch
        public int timestamp => (int)DateTime.Now.Subtract(new DateTime(1970, 1, 1)).TotalSeconds;

    }
}
