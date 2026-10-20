fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn BasicAddition() {
        assert_eq!(add(2, 3), 5);
    }
}
