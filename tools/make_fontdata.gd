extends SceneTree

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_args()
	if args.size() < 2:
		printerr("usage: ... --script make_fontdata.gd -- <src.ttf> <out.fontdata>")
		quit(1)
		return
	var ff := FontFile.new()
	var err: Error = ff.load_dynamic_font(args[0])
	if err != OK:
		printerr("load fail: ", err)
		quit(1)
		return
	var e2: Error = ResourceSaver.save(ff, args[1])
	print("saved ", args[1], " err=", e2, " cyr_B=", ff.has_char(0x0411))
	quit(0 if e2 == OK else 1)
