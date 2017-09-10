// all AAF arsenal categories
AS_AAFarsenal_fnc_all = {"aaf_arsenal" call AS_fnc_objects};

AS_AAFarsenal_fnc_get = {
	params ["_category", "_property"];
    ["aaf_arsenal", _category, _property] call AS_fnc_object_get
};

AS_AAFarsenal_fnc_set = {
    params ["_category", "_property", "_value"];
    ["aaf_arsenal", _category, _property, _value] call AS_fnc_object_set;
};

// the current vehicles of a given category or list of categories.
// If no argument is provided, returns all vehicles of all categories
AS_AAFarsenal_fnc_count = {
	private _categories = _this;
	if (typeName _categories == "STRING") then {
		_categories = [_this];
	};
	if (isNil "_categories") then {
		_categories = call AS_AAFarsenal_fnc_all;
	};
	private _all = 0;
	{_all = _all + ([_x, "count"] call AS_AAFarsenal_fnc_get)} forEach _categories;
    _all
};

// the valid vehicles of a given category or list of categories.
// If no argument is provided, returns all valid vehicles of all categories
AS_AAFarsenal_fnc_valid = {
	private _categories = _this;
	if (typeName _categories == "STRING") then {
		_categories = [_this];
	};
	if (isNil "_categories") then {
		_categories = call AS_AAFarsenal_fnc_all;
	};
	private _all = [];
	{_all append ([_x, "valid"] call AS_AAFarsenal_fnc_get)} forEach _categories;
    _all
};

// the maximum number of vehicles of a given category.
AS_AAFarsenal_fnc_max = {
	switch _this do {
		case "planes";
		case "armedHelis": {count (["airfield","AAF"] call AS_fnc_location_TS)};
		case "transportHelis": {2*(count (["airfield","AAF"] call AS_fnc_location_TS))};
		case "tanks": {count (["base","AAF"] call AS_fnc_location_TS)};
		case "boats": {count (["seaport","AAF"] call AS_fnc_location_TS)};
		case "apcs";
		case "trucks": {2*(count (["base","AAF"] call AS_fnc_location_TS))};
		case "supplies": {4 + round((count (["base","AAF"] call AS_fnc_location_TS))/2)};
	}
};

// the value of buying (AAF) a vehicle of a given category.
AS_AAFarsenal_fnc_cost = {
    [_this, "cost"] call AS_AAFarsenal_fnc_get
};

// the value of selling (FIA) a vehicle of a given category.
AS_AAFarsenal_fnc_value = {
    [_this, "value"] call AS_AAFarsenal_fnc_get
};

// a presentable name of the category.
AS_AAFarsenal_fnc_name = {
	[_this, "name"] call AS_AAFarsenal_fnc_get
};

// given a vehicle type (`typeOf _veh`), returns its category (or "" if it belongs to none)
AS_AAFarsenal_fnc_category = {
	params ["_type"];
	private _category = "";
	{
		if (_type in (_x call AS_AAFarsenal_fnc_valid)) exitWith {_category = _x;};
	} forEach call AS_AAFarsenal_fnc_all;
	_category
};

// Returns whether the category has space for more vehicles.
AS_AAFarsenal_fnc_canAdd = {
    (_this call AS_AAFarsenal_fnc_count) < (_this call AS_AAFarsenal_fnc_max)
};

// Adds a vehicle to the arsenal.
// Returns whether it was added or not
AS_AAFarsenal_fnc_addVehicle = {
	private _count = _this call AS_AAFarsenal_fnc_count;
	[_this, "count", _count + 1] call AS_AAFarsenal_fnc_set;
};

// Removes the vehicle type from the arsenal.
AS_AAFarsenal_fnc_deleteVehicle = {
    params ["_type"];
	private _category = [_type] call AS_AAFarsenal_fnc_category;
	private _count = _category call AS_AAFarsenal_fnc_count;
	[_category, "count", _count - 1] call AS_AAFarsenal_fnc_set;
};

// Initializes the AAF Arsenal.
AS_AAFarsenal_fnc_init = {
	["aaf_arsenal", true] call AS_fnc_container_add;

	// AAF will only buy and use vehicles of the types added here. See template.
	private _names = [
		"Supply trucks", "Trucks", "APCs", "Boats",
		"Transport Helicopters", "Tanks", "Armed Helicopters", "Planes"
	];
	// The list of all categories. Order defines what is bought first at AAFeconomics.sqf.
	private _categories = [
		"supplies", "trucks", "apcs", "boats", "transportHelis", "tanks", "armedHelis", "planes"
	];
	private _costs = [600, 600, 5000, 600, 10000, 4000, 10000, 20000];

	{
		["aaf_arsenal", _x] call AS_fnc_object_add;
		[_x, "name", _names select _forEachIndex] call AS_AAFarsenal_fnc_set;
		[_x, "count", 0] call AS_AAFarsenal_fnc_set;
		[_x, "cost", _costs select _forEachIndex] call AS_AAFarsenal_fnc_set;
		[_x, "valid", []] call AS_AAFarsenal_fnc_set;
		[_x, "value", (_costs select _forEachIndex)/2] call AS_AAFarsenal_fnc_set;
	} forEach _categories;
};

AS_AAFarsenal_fnc_save = {
	params ["_saveName"];
	["aaf_arsenal", _saveName] call AS_fnc_object_save;
};

AS_AAFarsenal_fnc_load = {
	params ["_saveName"];
	"aaf_arsenal" call AS_fnc_container_remove;
	call AS_AAFarsenal_fnc_init;
	["aaf_arsenal", _saveName] call AS_fnc_object_load;
};
