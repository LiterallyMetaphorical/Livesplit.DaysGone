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
        // Start of Diamond Lake
        {"SHERMAN'S CAMP IS CRAWLIN","Sherman's Camp Is Crawling OR ends Lost Lake run - Unsure, need more info"}, // Moves from No Place Else To Go - Sherman's Camp Is Crawling OR ends Lost Lake run
        {"I NEED YOUR HELP","I Need Your Help - Unsure, need more info"}, // Moves from Sherman's Camp Is Crawling - I Need Your Help
        {"SEARCHING FOR LISA","Searching For Lisa - Unsure, need more info"},
        {"NOW YOU SEE IT","Now You See It - Unsure, need more info"},
        {"PLAYING ALL NIGHT","Playing All Night - Unsure, need more info"},
        {"WITH OTHER MEN'S BLOOD","With Other Men's Blood - Unsure, need more info"},
        {"IT'S ON A MISSION","It's On A Mission - Unsure, need more info"},
        // Return to Iron Mikes Camp is called here, but its called for a side quest potentially a bunch of times so best not to track it
        {"A GODDAMN WAR ZONE","A Goddamn War Zone - Unsure, need more info"},
        {"FLOW LIKE BURIED RIVERS","Flow Like Buried Rivers - Unsure, need more info"},
        {"YOU SEE WHAT THEY DID","You See What They Did - Unsure, need more info"},
        {"DO YOU HAVE MY BACK?","Do You Have My Back? - Unsure, need more info"},
        //The next two splits can be done in either order
        {"I COULD USE A HAND","I Could Use A Hand - Unsure, need more info"},
        {"ON HEROD'S BIRTHDAY","On Herod's Birthday - Unsure, need more info"},
        {"SEEDS FOR THE SPRING","Seeds For The Spring - Unsure, need more info"},
        {"I GOT A JOB FOR YOU","I Got A Job For You - Unsure, need more info"},
        {"IT COULDN'T BE THAT EASY","It Couldn't Be That Easy - Unsure, need more info"},
        {"THEY DON'T LIKE VISITORS","They Don't Like Visitors - Unsure, need more info"},
        {"THAT'S WHEN I KNEW","That's When I Knew - Unsure, need more info"},
        {"IT'S A LONG STORY","It's A Long Story - Unsure, need more info"},
        {"MOMENTS OF LUCIDITY","Moments of Lucidity - Unsure, need more info"},
        {"RIDING THE OPEN ROAD","Riding The Open Road - Unsure, need more info"},
        {"THE ONLY ONE HE'S GOT","The Only One He's Got - Unsure, need more info"},
        {"I GOT WORK TO DO","I Got Work To Do - Unsure, need more info"},
        {"SOME KINDA FREAK EXPERT","Some Kinda Freak Expert - Unsure, need more info"},
        {"LINES NOT CROSSED","Lines Not Crossed - Unsure, need more info"},
        {"WE'RE NOT HIDING","We're Not Hiding - Unsure, need more info"},
        {"THAT'S HIS MISTAKE","That's His Mistake - Unsure, need more info"},
        {"DRINKING HIMSELF TO DEATH","Drinking Himself To Death - Unsure, need more info"},
        {"ABOUT BOOZER'S ARM","About Boozer's Arm - Unsure, need more info"},
        {"WAS THIS A GOOD IDEA?","Was This A Good Idea? - Unsure, need more info"},
        {"YOU TWISTED MY ARM","You Twisted My Arm - Unsure, need more info"},
        {"YOU COULD HAVE DONE MORE","You Could Have Done More - Unsure, need more info"},
        {"NOT LIKE I GOT A CHOICE","Not Like I Got A Choice - Unsure, need more info"},
        {"NO BEGINNING AND NO END","No Beginning And No End - Unsure, need more info"},
        {"BETTER TO LIGHT ONE CANDL","Better To Light One Candl(e) - Unsure, need more info"},
        {"OUTTA THE DARKNESS","Outta The Darkness - Unsure, need more info"},
        {"SOMETHING TO HEAL HIS SOU","Something To Heal His Sou(l) - Unsure, need more info"},
        {"HAVE IT YOUR WAY","Have It Your Way - Unsure, need more info"},
        {"TRYING TO HELP THE CAMP","Trying To Help The Camp - Unsure, need more info"},
        {"DON'T GET CAUGHT","Don't Get Caught - Unsure, need more info"},
        {"THEY DON'T FEEL PAIN","They Don't Feel Pain - Unsure, need more info"},
        {"IT WAS THE ONLY WAY","It Was The Only Way - Unsure, need more info"},
        {"I KEPT MY NAME","I Kept My Name - Unsure, need more info"},
        {"SHOULD HAVE SEEN IT COMIN","Should Have Seen It Comin - Unsure, need more info"},
        {"RIDERS SENT TO FIND YOU","Riders Sent To Find You - Unsure, need more info"},
        {"THEY WILL NEVER STOP","They Will Never Stop - Unsure, need more info"},
        {"WITHOUT BEING SEEN","Without Being Seen - Unsure, need more info"},
        {"YOU WON'T BE NEEDING THIS","You Won't Be Needing This - Unsure, need more info"},
        {"NOW THAT'S AN IDEA","Now That's An Idea - Unsure, need more info"},
        {"THAT NEVER GETS OLD","That Never Gets Old - Unsure, need more info"},
        {"TIME FOR SOME PAYBACK","Time For Some Payback - Unsure, need more info"},
        {"I'M GOOD WITH THAT","I'm Good With That - Unsure, need more info"},
        {"I WAS DISTRACTED","I Was Distracted - Unsure, need more info"},
        {"WHY AM I HERE?","Why Am I Here? - Unsure, need more info"},
        {"RIDING NOMAD AGAIN","Riding Nomad Again - Unsure, need more info"},
        {"MAYDAY! MAYDAY!","Mayday! Mayday! - Unsure, need more info"},
        {"NOT FROM AROUND HERE","Not From Around Here - Unsure, need more info"},
        {"WE'RE FIGHTING A WAR","We're Fighting A War - Unsure, need more info"},
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
