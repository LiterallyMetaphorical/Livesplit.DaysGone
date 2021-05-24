// Days Gone load remover and autosplitter - pauses on loading screens, autostarts on first cutscene, autosplits on listed objectives
// Thanks to Ero for helping me with getting the autostart to start at 0.00

state("DaysGone")
{
    byte loading : 0x4257390, 0x98, 0x9C8, 0x1E0, 0x190;
    string50 objective : 0x42906B8, 0x28, 0xBA0, 0x210, 0;
    byte menuState : 0x449D27C;
}

init
{
	vars.loading = false;
    vars.menuState = false;
}

startup
  {
        vars.TimerStart = (EventHandler) ((s, e) => timer.IsGameTimePaused = true);
        timer.OnStart += vars.TimerStart;
	  	refreshRate=30;
		if (timer.CurrentTimingMethod == TimingMethod.RealTime)
// Asks user to change to game time if LiveSplit is currently set to Real Time.
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Days Gone",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
// Creates a text component at the bottom of the users LiveSplit layout displaying the current objective/quest state
		vars.SetTextComponent = (Action<string, string>)((id, text) =>
    {
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
        var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
        var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
        timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));

        textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
        textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }

        if (textSetting != null)
        textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
    });
// Declares the name of the text component
    settings.Add("quest_state", true, "Current Objective");

// Dictionary containing all of the available objectives/quest states that can be split on	
	vars.objectivename = new Dictionary<string,string>
	{
        {"WE'LL MAKE IT QUICK","We'll Make It Quick - Finished the motorcycle ride"}, // Moves from He Can't Be Far - We'll Make It Quick	
        {"BAD WAY TO GO OUT","Bad Way To Go Out - Finished combat tutorial"}, // Moves from We'll Make It Quick - Bad Way To Go Out
        {"YOU GOT A DEATH WISH","You Got A Deathwish - Finished tunnel combat section"}, // Moves from Bad Way To Go Out - You Got A Deathwish
        {"DRIFTERS ON THE MOUNTAIN","Drifters on the Mountain - Reached safehouse for the 1st time"}, // Moves from You Got A Deathwish - Drifters on the Mountain
        {"BUGGED THE HELL OUT","Bugged The Hell Out - Finished at Copelands camp for the 1st time"}, // Drifters on the Mountain - Bugged The Hell Out
        {"NO STARVING PATRIOTS","No Starving Patriots - Unsure, need more info"}, // Moves from Drifters on the Mountain - No Starving Patriots
        {"SOUNDED LIKE ENGINES","Sounded Like Engines - Unsure, need more info"}, // Moves from No Starving Patriots - Sounded Like Engines
        {"SMOKE ON THE MOUNTAIN","Smoke On The Mountain - Unsure, need more info"}, // Moves from You Got A Deathwish - Smoke On The Mountain
        {"CLEAR OUT THOSE NESTS","Clear Out Those Nests - Unsure, need more info"}, // Moves from Smoke On The Mountain - Clear Out Those Nests
        //NOTE that NESTS probably gets called a lot, may not be good to split on
        {"OUT OF NOWHERE","Out Of Nowhere - Unsure, need more info"}, // Moves from Clear Out Those Nests - Out Of Nowhere
        {"THEY'RE NOT SLEEPING","They're Not Sleeping - Unsure, need more info"}, // Moves from Clear Out Those Nests - They're Not Sleeping
        {"PRICE ON YOUR HEAD","Price On Your Head - Unsure, need more info"}, // Moves from They're Not Sleeping - Price On Your Head
        {"DRUGGED OUTTA HIS MIND","Drugged Outta His Mind - Unsure, need more info"}, // Moves from Price On Your Head - Drugged Outta His Mind
        {"WHAT DID YOU DO?","What Did You Do? - Unsure, need more info"}, // Moves from Drugged Outta His Mind - What Did You Do?
        {"SEARCHING FOR SOMETHING","Searching For Something - Unsure, need more info"}, // Moves from What Did You Do? - Searching For Something
        {"IT'S NOT SAFE HERE","It's Not Safe Here - Unsure, need more info"}, // Moves from Searching For Something - It's Not Safe Here
        {"LOTS OF SICK PEOPLE","Lots Of Sick People - Unsure, need more info"}, // Moves from It's Not Safe Here - Lots Of Sick People
        {"IT'S A RIFLE, NOT A GUN","It's A Rifle, Not A Gun - Unsure, need more info"}, // Moves from Lots Of Sick People - It's A Rifle, Not A Gun
        {"MAKING CONTACT","Making Contact - Unsure, need more info"}, // Moves from It's A Rifle, Not A Gun - Making Contact
        {"WE'RE GETTING LOW ON MEAT","We're Getting Low on Meat - Unsure, need more info"}, // Moves from Making Contact - We're Getting Low on Meat
        {"THEY WON'T LET ME LEAVE","They Won't Let Me Leave - Unsure, need more info"}, // Moves from We're Getting Low on Meat - They Won't Let Me Leave
        {"THE REST OF OUR DRUGS","The Rest of Our Drugs - Unsure, need more info"}, // Moves from They Won't Let Me Leave - The Rest of Our Drugs
        {"I BROUGHT YOU SOMETHING","I Brought You Something - Unsure, need more info"}, // Moves from The Rest of Our Drugs - I Brought You Something
        {"I'VE PULLED WEEDS BEFORE","I've Pulled Weeds Before - Unsure, need more info"}, // Moves from I Brought You Something - I've Pulled Weeds Before
        {"GIVE ME A COUPLE DAYS","Give Me a Couple of Days - Unsure, need more info"}, // Moves from I've Pulled Weeds Before - Give Me a Couple of Days
        {"WHAT HAVE THEY DONE","What Have They Done - Unsure, need more info"}, // Moves from Give Me a Couple of Days - What Have They Done
        {"NO ONE SAW IT COMING","No One Saw It Coming - Unsure, need more info"}, // Moves from What Have They Done - No One Saw It Coming
        {"NOT GONNA KILL ANYONE","Not Gonna Kill Anyone - Unsure, need more info"}, // Moves from No One Saw It Coming - Not Gonna Kill Anyone
        {"NO PLACE ELSE TO GO","No Place Else To Go - Unsure, need more info"}, // Moves from Not Gonna Kill Anyone - No Place Else To Go
        {"WE'VE ALL DONE THINGS","We've All Done Things - Unsure, need more info"}, // Moves from No Place Else To Go - We've All Done Things
        {"SHERMAN'S CAMP IS CRAWLIN","Sherman's Camp Is Crawling OR ends Lost Lake run - Unsure, need more info"}, // Moves from No Place Else To Go - Sherman's Camp Is Crawling OR ends Lost Lake run
	};
	
// split on specified objectives
	settings.Add("Quest States", true);
// Add objectives to setting list
	foreach (var script in vars.objectivename) {
		settings.Add(script.Key, true, script.Value, "Quest States");
	}
}

start
{
    return (current.menuState == 1 && current.loading == 255);
}

update
{
    //tells isLoading to look for the value of 0
        vars.loading = current.loading == 255;

    //creates the text component if the quest state option is selected
        	    if (settings["quest_state"]) 
            {
            vars.SetTextComponent("Current Objective", (current.objective)); 
            }
       
}

split
{
	return current.objective != old.objective && old.objective != null && settings[current.objective];
}

isLoading
{
    return vars.loading;
}

shutdown
{
    timer.OnStart -= vars.TimerStart;
}
