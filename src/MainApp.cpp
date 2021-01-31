#include <string>
#include <sstream>
#include <Urho3D/Urho3DAll.h>

using namespace Urho3D;


/**
* Using the convenient Application API we don't have
* to worry about initializing the engine or writing a main.
* You can probably mess around with initializing the engine
* and running a main manually, but this is convenient and portable.
*/
class MainApp : public Application
{

public:

	/**
	* This happens before the engine has been initialized
	* so it's usually minimal code setting defaults for
	* whatever instance variables you have.
	* You can also do this in the Setup method.
	*/
	MainApp(Context* context) : Application(context)
	{

	}

	/**
	* This method is called before the engine has been initialized.
	* Thusly, we can setup the engine parameters before anything else
	* of engine importance happens (such as windows, search paths,
	* resolution and other things that might be user configurable).
	*/
	virtual void Setup()
	{
		// These parameters should be self-explanatory.
		// See http://urho3d.github.io/documentation/1.7/_main_loop.html
		// for a more complete list.
		engineParameters_[EP_FULL_SCREEN] = false;
		engineParameters_[EP_LOG_NAME] = "cinemabump.log";
		engineParameters_[EP_SOUND] = true;
		// Configuration not depending whether we compile for debug or release.
		engineParameters_[EP_WINDOW_WIDTH] = 1280;
		engineParameters_[EP_WINDOW_HEIGHT] = 720;

		// All 'EP_' constants are defined in ${URHO3D_INSTALL}/include/Urho3D/Engine/EngineDefs.h file
	}

	/**
	* This method is called after the engine has been initialized.
	* This is where you set up your actual content, such as scenes,
	* models, controls and what not. Basically, anything that needs
	* the engine initialized and ready goes in here.
	*/
	virtual void Start()
	{
		// Instantiate and register the Lua script subsystem
		auto* luaScript = new LuaScript(context_);
		context_->RegisterSubsystem(luaScript);

		// If script loading is successful, proceed to main loop
		if (luaScript->ExecuteFile("LuaScripts/cinema_bump.lua"))
		{
			luaScript->ExecuteFunction("Start");
			return;
		}
	}

	/**
	* Good place to get rid of any system resources that requires the
	* engine still initialized. You could do the rest in the destructor,
	* but there's no need, this method will get called when the engine stops,
	* for whatever reason (short of a segfault).
	*/
	virtual void Stop()
	{
		URHO3D_LOGINFO("--STOPPING--");
	}

};


/**
* This macro is expanded to (roughly, depending on OS) this:
*
* > int RunApplication()
* > {
* > Urho3D::SharedPtr<Urho3D::Context> context(new Urho3D::Context());
* > Urho3D::SharedPtr<className> application(new className(context));
* > return application->Run();
* > }
* >
* > int main(int argc, char** argv)
* > {
* > Urho3D::ParseArguments(argc, argv);
* > return function;
* > }
*/
URHO3D_DEFINE_APPLICATION_MAIN(MainApp)