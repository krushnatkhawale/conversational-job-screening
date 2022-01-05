import "commonReactions/all.dsl";


context
{
    // declare input variables here. phone must always be declared. name is optional
    input phone: string;
    input name: string = "";
    
    // declare storage variables here
    var1: string = "";
    
    profile: {
        designation: string; experience: string; employment_type: string; key_skills: [];
    } = {
        designation: "", experience: "", employment_type: "", key_skills: []
    };
}

// declare external functions here
external function function1(log: string): string;
external function addToSkills(skillsArray: unknown): [];
external function postProfile(profile: unknown): string;

// lines 28-42 start node
start node root
{
    do //actions executed in this node
    {
        #connectSafe($phone); // connecting to the phone number which is specified in index.js that it can also be in-terminal text chat
        #waitForSpeech(1000); // give the person a second to start speaking
        #say("greeting",
        {
            name: $name
        }
        ); // and greet them. Refer to phrasemap.json > "greeting" (line 12); note the variable $name for phrasemap use
        wait *;
    }
    transitions // specifies to which nodes the conversation goes from here
    {
        yes: goto question_1 on #messageHasIntent("yes"); // feel free to modify your own intents for "yes" and "no" in data.json
        no: goto callback on #messageHasIntent("no");
    }
}

node question_1
{
    do
    {
        #say("question_1");
        wait *;
    }
    transitions
    {
        q1evaluate: goto q1evaluate on #messageHasData("designation");
    }
}

node q1evaluate
{
    do
    {
        set $profile.designation = #messageGetData("designation")[0]?.value??"";
        goto question_2;
    }
    transitions
    {
        question_2: goto question_2;
    }
}

node question_2
{
    do
    {
        #say("question_2");
        wait *;
    }
    transitions
    {
        q1evaluate: goto q2evaluate on #messageHasData("experience");
        no: goto no on #messageHasIntent("no");
    }
}

node q2evaluate
{
    do
    {
        set $profile.experience = #messageGetData("experience")[0]?.value??"";
        external function1("Experience is ");
        external function1($profile.experience);
        var expFloat = #parseFloat($profile.experience);
        if(expFloat >=0 && expFloat<50){
            goto question_3;
        }
    }
    transitions
    {
        no: goto no on #messageHasIntent("no");
        question_3: goto question_3;
    }
}


node question_3
{
    do
    {
        #say("question_3");
        wait *;
    }
    transitions
    {
        q3evaluate: goto q3evaluate on #messageHasData("employment_type");
        no: goto no on #messageHasIntent("no");
    }
}


node q3evaluate
{
    do
    {
        set $profile.employment_type = #messageGetData("employment_type")[0]?.value??"";
        external function1("Employment_type is ");
        external function1($profile.employment_type);
        goto question_4;
    }
    transitions
    {
        no: goto no on #messageHasIntent("no");
        question_4: goto question_4;
    }
}

node question_4
{
    do
    {
        #say("question_4");
        wait *;
    }
    transitions
    {
        q4evaluate: goto q4evaluate on #messageHasData("key_skills");
    }
}


node q4evaluate
{
    do
    {
        var key_skills_tmp = #messageGetData("key_skills");
        var skills = external addToSkills(key_skills_tmp);

        set $profile.key_skills = skills;
        goto close_questionnaire;
    }
    transitions
    {
        no: goto no on #messageHasIntent("no");
        close_questionnaire: goto close_questionnaire;
    }
}

node close_questionnaire
{
    do
    {
        external postProfile($profile);
        #say("close_questionnaire");
        exit;
    }
}

node callback
{
    do
    {
        #say("callback");
        exit;
    }
}

// lines 73-333 are our perfect world flow
node yes
{
    do
    {
        var result = external function1("test");    //call your external function
        #say("yes"); //call on phrase "question_1" from the phrasemap
        exit;
    }
}

node no
{
    do
    {
        #say("no");
        exit;
    }
}

digression how_are_you
{
    conditions
    {
        on #messageHasIntent("how_are_you");
    }
    do
    {
        #sayText("I'm well, thank you!", repeatMode: "ignore");
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node
        return; // go back to the node from which we got distracted into the digression
    }
}
