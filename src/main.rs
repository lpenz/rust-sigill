#[derive(Debug)]
pub enum Type {
    TYPE1,
    TYPE2,
}

#[derive(Debug)]
pub struct Data {
    pub ctype: Type,
    pub int: i32,
}

#[derive(Debug)]
pub struct Entity {
    pub idata: usize,
    pub modifier: Option<Data>,
}

impl Entity {
    pub fn data(&self) -> &Data {
        if self.modifier.is_none() {
            &DATA[self.idata]
        } else {
            self.modifier.as_ref().unwrap()
        }
    }
}

pub const DATA: [Data; 1] = [Data {
    ctype: Type::TYPE2,
    int: 1,
}];

pub fn main() {
    let mut itemvec = vec![Entity {
        idata: 0,
        modifier: None,
    }];
    eprintln!("vec[0]: {:p} = {:?}", &itemvec[0], itemvec[0]);
    eprintln!("removed item 0");
    let item = itemvec.remove(0);
    eprintln!("item: {:p} = {:?}", &item, item);
    eprintln!("modifier: {:p} = {:?}", &item.modifier, item.modifier);
    eprintln!("DATA: {:p} = {:?}", &DATA[0], DATA[0]);
    let itemdata = item.data();
    eprintln!("itemdata: {:p} = {:?}", itemdata, itemdata);
}
