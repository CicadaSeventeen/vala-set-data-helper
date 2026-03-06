namespace SetDataHelper
{
	private class ItemBox<T>: Object {
		internal T item;
		internal ItemBox(T item){
			this.item = item;
		}
	}

	private class ArrayBox<T>: Object {
		internal T[]? array;
		internal ArrayBox(T[] array){
			this.array = array;
		}
	}

	public class SetData: Object {
		private weak GLib.Object object;
		private string key;
		protected unowned GLib.Object? box {
			get{
				unowned GLib.Object? tmp = this.object.get_data<GLib.Object>(this.key);
				if(tmp==null){return null;}
				return tmp;
			}
			set{
				this.object.set_data<GLib.Object>(this.key,value);
			}
		}
		public bool has_content(){
			unowned GLib.Object? tmp = this.object.get_data<GLib.Object>(this.key);
			return (tmp == null)? false : true;
		}
		protected SetData(GLib.Object object,string key){
			this.object = object;
			this.key = key;
			this.box = null;
		}
		protected SetData.with_data(GLib.Object object,GLib.Object data,string key){
			this.object = object;
			this.key = key;
			this.box = data;
		}
	}

	public class SetData_Var<T>: SetData {
		public SetData_Var(GLib.Object object,string key){
			base(object,key);
		}
		public SetData_Var.with_data(GLib.Object object, T data, string key){
			base.with_data(object,new ItemBox<T>(data),key);
		}
		public unowned T? content_ref{
			get{
				unowned ItemBox<T> tmp = (this.box as ItemBox<T>);
				if (tmp == null){critical("data box is empty.");return null;}
				else{return tmp.item;}
			}
			set{
				unowned ItemBox<T> tmp = (this.box as ItemBox<T>);
				if(tmp == null){
					this.box = new ItemBox<T>(value);
				}
				else{
					tmp.item = value;
				}
			}
		}
		public owned T? content{
			get{
				ItemBox<T> tmp = (this.box as ItemBox<T>);
				if (tmp == null){critical("data box is empty.");return null;}
				else{return tmp.item;}
			}
			set{
				this.box = new ItemBox<T>(value);
			}
		}
	}

	public class SetData_Array<T>: SetData {
		public PseudoArray<T>? array;
		public SetData_Array(GLib.Object object,string key){
			base(object,key);
			this.array = new PseudoArray<T>(this);
		}
		public SetData_Array.with_data(GLib.Object object, T[]? data, string key){
			if(data == null){warning("data is null, expected array.");}
			base.with_data(object,new ArrayBox<T>(data),key);
			this.array = new PseudoArray<T>(this);
		}
		public unowned T[]? content_ref{
			get{
				unowned ArrayBox<T> tmp = (this.box as ArrayBox<T>);
				if (tmp == null){critical("data box is empty.");return null;}
				else{return tmp.array;}
			}
		}
		public owned T[]? content{
			get{
				owned ArrayBox<T> tmp = (this.box as ArrayBox<T>);
				if (tmp == null){critical("data box is empty.");return null;}
				else{return tmp.array;}
			}
			set{
				this.box = new ArrayBox<T>(value);
			}
		}
		public int length{
			get{
				return (this.box as ArrayBox<T>).array.length;
			}
		}
		public class PseudoArray<T>: Object{
			private weak SetData_Array<T> mother;
			private void bug_0(){
				if(typeof(T).is_value_type()){message("Known Bug: .array is buggy when using value type. Please use .content and .content_ref instead.");}
			}
			public PseudoArray(SetData_Array mother){
				this.mother = mother;
			}
			public new T? get(int index){
				owned ArrayBox<T> tmp = (this.mother.box as ArrayBox<T>);
				if (tmp == null){critical("data box is empty.");return null;}
				if (index < 0 || index >= tmp.array.length){critical("index is out of length.");return null;}
				this.bug_0();
				return tmp.array[index];
			}
			public new void set(int index,T? item){
				unowned ArrayBox<T> tmp = (this.mother.box as ArrayBox<T>);
				if(item == null){warning("new data is null.");}
				if (index < 0 || index >= tmp.array.length){critical("index is out of length.");return;}
				this.bug_0();
				tmp.array[index] = item;
			}
			public int length {
				get{
					return this.mother.length;
				}
			}
		}
	}

	public class SetData_GObject: SetData {
		public SetData_GObject(GLib.Object object,string key){
			base(object,key);
		}
		public SetData_GObject.with_data(GLib.Object object, GLib.Object? data, string key){
			if (data == null){warning("new data is null.");}
			base.with_data(object,data,key);
		}
		public unowned GLib.Object? content_ref{
			get{
				return this.box;
			}
		}
		public owned GLib.Object? content{
			get{
				return this.box;
			}
			set{
				if(value == null){warning("value is null.");}
				this.box = value;
			}
		}
	}
}
